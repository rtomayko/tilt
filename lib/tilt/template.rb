module Tilt
  TOPOBJECT = defined?(BasicObject) ? BasicObject : Object

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

    # Used to determine if this class's initialize_engine method has
    # been called yet.
    @engine_initialized = false
    class << self
      attr_accessor :engine_initialized
      alias engine_initialized? engine_initialized

      attr_accessor :default_mime_type
    end

    # Create a new template with the file, line, and options specified. By
    # default, template data is read from file and assumed to be in the
    # system default external encoding (Encoding.default_external). When a
    # block is given, it should read template data and return a String with
    # a best guess encoding.
    #
    # The :default_encoding option is supported by most template engines. When
    # set, data read from disk will be assumed to be in this encoding instead
    # of Encoding.default_external. The option has no effect when a custom
    # reader block is given.
    #
    # All arguments are optional but a file or block must be specified.
    def initialize(file=nil, line=1, options={}, &block)
      @file, @line, @options = nil, 1, {}

      [options, line, file].compact.each do |arg|
        case
        when arg.respond_to?(:to_str)  ; @file = arg.to_str
        when arg.respond_to?(:to_int)  ; @line = arg.to_int
        when arg.respond_to?(:to_hash) ; @options = arg.to_hash.dup
        else raise TypeError
        end
      end

      raise ArgumentError, "file or block required" if (@file || block).nil?

      # call the initialize_engine method if this is the very first time
      # an instance of this class has been created.
      if !self.class.engine_initialized?
        initialize_engine
        self.class.engine_initialized = true
      end

      # used to hold compiled template methods
      @compiled_method = {}

      # Overrides Encoding.default_external when reading from filesystem
      @default_encoding = @options.delete :default_encoding

      # load template data and prepare (uses binread to avoid encoding issues)
      @reader = block || method(:read_template_file)
      @data = @reader.call(self)
      prepare
    end

    # Render the template in the given scope with the locals specified. If a
    # block is given, it is typically available within the template via
    # +yield+.
    def render(scope=Object.new, locals={}, &block)
      evaluate scope, locals || {}, &block
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

  protected
    # Called once and only once for each template subclass the first time
    # the template class is initialized. This should be used to require the
    # underlying template library and perform any initial setup.
    def initialize_engine
    end

    # Read template data from file, possibly overriding the encoding based on
    # the default_encoding option. This is used when the object is created with
    # a file and no reader block.
    #
    # Unlike File.read, this method does not transcode into the system
    # Encoding.default_internal encoding. The best guess encoding is set and
    # available from data.encoding.
    #
    # Subclasses may override this method if they have specific knowledge about
    # the file's encoding and can provide better default encoding support.
    #
    # Raise exception when file doesn't exist.
    # Does not raise an exception when the file's data is invalid in the best
    # guess encoding.
    def read_template_file(template=self)
      data = File.open(template.file, 'rb') { |io| io.read }
      if data.respond_to?(:force_encoding)
        encoding = @default_encoding || Encoding.default_external
        data.force_encoding(encoding)
      end
      data
    end

    # Like Kernel#require but issues a warning urging a manual require when
    # running under a threaded environment.
    def require_template_library(name)
      if Thread.list.size > 1
        warn "WARN: tilt autoloading '#{name}' in a non thread-safe way; " +
             "explicit require '#{name}' suggested."
      end
      require name
    end

    # Do whatever preparation is necessary to setup the underlying template
    # engine. Called immediately after template data is loaded. Instance
    # variables set in this method are available when #evaluate is called.
    #
    # Subclasses must provide an implementation of this method.
    #
    # The data attribute holds the template source string marked with the best
    # guess encoding. When the template was read from the filesystem this will
    # be either the :default_encoding provided when the template was created or
    # the system default Encoding.default_external encoding. When the template
    # data was provided via reader block, it will be in whatever encoding was
    # set on the string originally. Subclasses are responsible for detecting
    # template specific magic syntax encodings embedded in the template data.
    def prepare
      if respond_to?(:compile!)
        # backward compat with tilt < 0.6; just in case
        warn 'Tilt::Template#compile! is deprecated; implement #prepare instead.'
        compile!
      else
        raise NotImplementedError
      end
    end

    def evaluate(scope, locals, &block)
      cached_evaluate(scope, locals, &block)
    end

    # Process the template and return the result. The first time this
    # method is called, the template source is evaluated with instance_eval.
    # On the sequential method calls it will compile the template to an
    # unbound method which will lead to better performance. In any case,
    # template executation is guaranteed to be performed in the scope object
    # with the locals specified and with support for yielding to the block.
    def cached_evaluate(scope, locals, &block)
      # Redefine itself to use method compilation the next time:
      def self.cached_evaluate(scope, locals, &block)
        method = compiled_method(locals.keys)
        method.bind(scope).call(locals, &block)
      end

      # Use instance_eval the first time:
      evaluate_source(scope, locals, &block)
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

      source = ''
      if source.respond_to?(:force_encoding)
        source.force_encoding template.encoding
      end

      source << preamble
      source << "\n"
      source << template
      source << "\n"
      source << precompiled_postamble(locals)

      [source, preamble.count("\n") + 1]
    end

    # A string containing the (Ruby) source code for the template. The
    # default Template#evaluate implementation requires either this method
    # or the #precompiled method be overridden. When defined, the base
    # Template guarantees correct file/line handling, locals support, custom
    # scopes, and support for template compilation when the scope object
    # allows it.
    def precompiled_template(locals)
      raise NotImplementedError
    end

    # Generates preamble code for initializing template state, and performing
    # locals assignment. The default implementation performs locals
    # assignment only. Lines included in the preamble are subtracted from the
    # source line offset, so adding code to the preamble does not effect line
    # reporting in Kernel::caller and backtraces.
    def precompiled_preamble(locals)
      locals.map { |k,v| "#{k} = locals[#{k.inspect}]" }.join("\n")
    end

    # Generates postamble code for the precompiled template source. The
    # string returned from this method is appended to the precompiled
    # template source.
    def precompiled_postamble(locals)
      ''
    end

    # The compiled method for the locals keys provided.
    def compiled_method(locals_keys)
      @compiled_method[locals_keys] ||=
        compile_template_method(locals_keys)
    end

  private
    # Evaluate the template source in the context of the scope object.
    def evaluate_source(scope, locals, &block)
      source, offset = precompiled(locals)
      scope.instance_eval(source, eval_file, line - offset)
    end

    # JRuby doesn't allow Object#instance_eval to yield to the block it's
    # closed over. This is by design and (ostensibly) something that will
    # change in MRI, though no current MRI version tested (1.8.6 - 1.9.2)
    # exhibits the behavior. More info here:
    #
    # http://jira.codehaus.org/browse/JRUBY-2599
    #
    # We redefine evaluate_source to work around this issue.
    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
      undef evaluate_source
      def evaluate_source(scope, locals, &block)
        source, offset = precompiled(locals)
        file, lineno = eval_file, (line - offset)
        scope.instance_eval { Kernel::eval(source, binding, file, lineno) }
      end
    end

    def compile_template_method(locals)
      source, offset = precompiled(locals)
      offset += 5
      method_name = "__tilt_#{Thread.current.object_id.abs}"
      method_source = ""

      if method_source.respond_to?(:force_encoding)
        method_source.force_encoding source.encoding
      end

      method_source << <<-RUBY
        TOPOBJECT.class_eval do
          def #{method_name}(locals)
            Thread.current[:tilt_vars] = [self, locals]
            class << self
              this, locals = Thread.current[:tilt_vars]
              this.instance_eval do
      RUBY
      method_source << source
      method_source << <<-RUBY
              end
            end
          end
        end
      RUBY

      Object.class_eval method_source, eval_file, line - offset
      unbind_compiled_method(method_name)
    end

    def unbind_compiled_method(method_name)
      method = TOPOBJECT.instance_method(method_name)
      TOPOBJECT.class_eval { remove_method(method_name) }
      method
    end

    # Checks for a Ruby 1.9 encoding comment on the first line of source.
    # When found, source is modified in place to remove the line.
    #
    # Returns the declared encoding name string or nil when no comment was
    # present.
    def extract_source_encoding(source)
      if source.slice!(/\A[ \t]*\#.*coding\s*[=:]\s*([[:alnum:]\-_]+).*?\n/mn)
        $1
      end
    end

    # Special case Ruby 1.9.1's broken yield.
    #
    # http://github.com/rtomayko/tilt/commit/20c01a5
    # http://redmine.ruby-lang.org/issues/show/3601
    #
    # Remove when 1.9.2 dominates 1.9.1 installs in the wild.
    if RUBY_VERSION =~ /^1.9.1/
      undef compile_template_method
      def compile_template_method(locals)
        source, offset = precompiled(locals)
        offset += 1
        method_name = "__tilt_#{Thread.current.object_id}"
        Object.class_eval <<-RUBY, eval_file, line - offset
          TOPOBJECT.class_eval do
            def #{method_name}(locals)
              #{source}
            end
          end
        RUBY
        unbind_compiled_method(method_name)
      end
    end
  end
end
