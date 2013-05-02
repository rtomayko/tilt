require 'tilt'
require 'thread'

module Tilt
  TOPOBJECT = Object.superclass || Object
  LOCK = Mutex.new

  # Base class for template implementations. Subclasses must implement
  # the #prepare method and one of the #evaluate or #precompiled_template
  # methods.
  class Template
    # Template source; loaded from a file or given directly.
    attr_reader :data

    # The name of the file where the template data was loaded from.
    attr_reader :file

    # The line number in #file where template data was loaded from.
    attr_reader :line

    # A Hash of template engine specific options. This is passed directly
    # to the underlying engine and is not used by the generic template
    # interface.
    attr_reader :options

    class << self
      def metadata
        @metadata ||= {}
      end

      def default_mime_type
        warn ".default_mime_type has been replaced with .metadata[:mime_type]"
        metadata[:mime_type]
      end

      def default_mime_type=(value)
        metadata[:mime_type] = value
      end
    end

    # Create a new template with the file, line, and options specified. By
    # default, template data is read from the file. When a block is given,
    # it should read template data and return as a String. When file is nil,
    # a block is required.
    #
    # All arguments are optional.
    def initialize(file=nil, line=1, options={}, &block)
      @file, @line, @options = nil, 1, {}

      [options, line, file].compact.each do |arg|
        case
        when arg.respond_to?(:to_str)  ; @file = arg.to_str
        when arg.respond_to?(:to_int)  ; @line = arg.to_int
        when arg.respond_to?(:to_hash) ; @options = arg.to_hash.dup
        when arg.respond_to?(:path)    ; @file = arg.path
        else raise TypeError
        end
      end

      raise ArgumentError, "file or block required" if (@file || block).nil?

      # used to hold compiled template methods
      @compiled_method = {}

      # used on 1.9 to set the encoding if it is not set elsewhere (like a magic comment)
      # currently only used if template compiles to ruby
      @default_encoding = @options.delete :default_encoding

      # load template data and prepare (uses binread to avoid encoding issues)
      @reader = block || lambda { |t| read_template_file }
      @data = @reader.call(self)

      if @data.respond_to?(:force_encoding)
        @data.force_encoding(default_encoding) if default_encoding

        if !@data.valid_encoding?
          raise Encoding::InvalidByteSequenceError, "#{eval_file} is not valid #{@data.encoding}"
        end
      end

      prepare
    end

    # The encoding of the source data. Defaults to the
    # default_encoding-option if present. You may override this method
    # in your template class if you have a better hint of the data's
    # encoding.
    def default_encoding
      @default_encoding
    end

    def read_template_file
      data = File.open(file, 'rb') { |io| io.read }
      if data.respond_to?(:force_encoding)
        # Set it to the default external (without verifying)
        data.force_encoding(Encoding.default_external) if Encoding.default_external
      end
      data
    end

    # Render the template in the given scope with the locals specified. If a
    # block is given, it is typically available within the template via
    # +yield+.
    def render(scope=Object.new, locals={}, &block)
      current_template = Thread.current[:tilt_current_template]
      Thread.current[:tilt_current_template] = self
      evaluate(scope, locals, &block)
    ensure
      Thread.current[:tilt_current_template] = current_template
    end

    # The basename of the template file.
    def basename(suffix='')
      File.basename(file, suffix) if file
    end

    # The template file's basename with all extensions chomped off.
    def name
      basename.split('.', 2).first if basename
    end

    # The filename used in backtraces to describe the template.
    def eval_file
      file || '(__TEMPLATE__)'
    end

    def metadata
      if respond_to?(:real_allows_script?)
        self.class.metadata.merge(:allows_script => real_allows_script?)
      else
        self.class.metadata
      end
    end

    # Depricate the usage of allows_script?. Still allow template classes to define it, but 
    # allows_script? will now warn, and #metadata will include it.
    def self.method_added(name)
      if name == :allows_script?
        return if @defining_allows_script
        @defining_allows_script = true
        alias_method :real_allows_script?, :allows_script?
        define_method(:allows_script?) do
          warn ".allows_script? has been replaced with .metadata[:allows_script]"
          real_allows_script?
        end
        @defining_allows_script = false
      end
    end

  protected
    # Do whatever preparation is necessary to setup the underlying template
    # engine. Called immediately after template data is loaded. Instance
    # variables set in this method are available when #evaluate is called.
    #
    # Subclasses must provide an implementation of this method.
    def prepare
      raise NotImplementedError
    end

    # Execute the compiled template and return the result string. Template
    # evaluation is guaranteed to be performed in the scope object with the
    # locals specified and with support for yielding to the block.
    #
    # This method is only used by source generating templates. Subclasses that
    # override render() may not support all features.
    def evaluate(scope, locals, &block)
      method = compiled_method(locals.keys)
      method.bind(scope).call(locals, &block)
    end

    def precompile
      precompiled([])
    end

    # A string containing the (Ruby) source code for the template. The
    # default Template#evaluate implementation requires either this
    # method or the #precompiled method be overridden. When defined,
    # the base Template guarantees correct file/line handling, locals
    # support, custom scopes, proper encoding, and support for template
    # compilation.
    def precompile_template
      raise NotImplementedError
    end

    def precompile_preamble
      ''
    end

    def precompile_postamble
      ''
    end

    # Generates all template source by combining the preamble, template, and
    # postamble and returns a two-tuple of the form: [source, offset], where
    # source is the string containing (Ruby) source code for the template and
    # offset is the integer line offset where line reporting should begin.
    #
    # Template subclasses may override this method when they need complete
    # control over source generation or want to adjust the default line
    # offset. In most cases, overriding the #precompiled_template method is
    # easier and more appropriate.
    def precompiled(locals)
      preamble = precompiled_preamble(locals)
      template = precompiled_template(locals)
      postamble = precompiled_postamble(locals)
      source = ''

      # Ensure that our generated source code has the same encoding as the
      # the source code generated by the template engine.
      if source.respond_to?(:force_encoding)
        template_encoding = extract_encoding(template)

        source.force_encoding(template_encoding)
        template.force_encoding(template_encoding)
      end

      source << preamble << "\n" << template << "\n" << postamble

      [source, preamble.count("\n")+1]
    end

    def precompiled_template(locals)
      precompile_template
    end

    def precompiled_preamble(locals)
      precompile_preamble
    end

    def precompiled_postamble(locals)
      precompile_postamble
    end

    # The compiled method for the locals keys provided.
    def compiled_method(locals_keys)
      LOCK.synchronize do
        @compiled_method[locals_keys] ||= compile_template_method(locals_keys)
      end
    end

  private
    def local_extraction(local_keys)
      local_keys.map do |k|
        if k.to_s =~ /\A[a-z_][a-zA-Z_0-9]*\z/
          "#{k} = locals[#{k.inspect}]"
        else
          raise "invalid locals key: #{k.inspect} (keys must be variable names)"
        end
      end.join("\n")
    end

    def compile_template_method(local_keys)
      source, offset = self.precompile
      local_code = local_extraction(local_keys)

      method_name = "__tilt_#{Thread.current.object_id.abs}"
      method_source = ""

      if method_source.respond_to?(:force_encoding)
        method_source.force_encoding(source.encoding) 
      end

      method_source << <<-RUBY
        TOPOBJECT.class_eval do
          def #{method_name}(locals)
            Thread.current[:tilt_vars] = [self, locals]
            class << self
              this, locals = Thread.current[:tilt_vars]
              this.instance_eval do
                #{local_code}
      RUBY
      offset += method_source.count("\n")
      method_source << source
      method_source << "\nend;end;end;end"
      Object.class_eval(method_source, eval_file, line - offset)
      unbind_compiled_method(method_name)
    end

    def unbind_compiled_method(method_name)
      method = TOPOBJECT.instance_method(method_name)
      TOPOBJECT.class_eval { remove_method(method_name) }
      method
    end

    def extract_encoding(script)
      extract_magic_comment(script) || script.encoding
    end

    def extract_magic_comment(script)
      binary(script) do
        script[/\A[ \t]*\#.*coding\s*[=:]\s*([[:alnum:]\-_]+).*$/n, 1]
      end
    end

    def binary(string)
      original_encoding = string.encoding
      string.force_encoding(Encoding::BINARY)
      yield
    ensure
      string.force_encoding(original_encoding)
    end
  end
end
