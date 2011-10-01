require 'tilt/template'

module Tilt
  # Erector
  # http://github.com/erector/erector
  class ErectorTemplate < Template
    def self.builder_class
      @builder_class ||= Class.new(Erector::InlineWidget) do
        def scope= object
          @_parent = object
        end

        def method_missing name, *args, &block
          assigns[name] || @_parent.send(name, *args, &block)
        end
        
        def capture &block
          original, @_output = output, Erector::Output.new
          instance_eval &block
          original.widgets.concat(output.widgets) # todo: test!!!
          output.to_s
        ensure
          @_output = original
        end

        def content
          block ? template_content{ text capture(&block) } : template_content
        end
      end
    end

    def self.engine_initialized?
      defined? ::Erector
    end

    def initialize_engine
      require_template_library 'erector'
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      builder = self.class.builder_class.new(locals, &block)
      builder.scope = scope

      if data.kind_of? Proc
        (class << builder; self end).send(:define_method, :template_content, &data)
      else
        builder.instance_eval <<-CODE, __FILE__, __LINE__
          def template_content
            #{data}
          end
        CODE
      end

      # if block
      #   builder.__capture_erector_tilt__(&block)
      # end

      builder.to_html
    end
  end
end

