require 'tilt/template'

module Tilt

  # Yajl Template implementation
  #
  # Yajl is a fast JSON parsing and encoding library for Ruby
  # See https://github.com/brianmario/yajl-ruby
  #
  # The template source is evaluated as a Ruby string,
  # and the result is converted #to_json.
  class YajlTemplate < Template

    self.default_mime_type = 'application/json'

    def self.engine_initialized?
      defined? ::Yajl
    end

    def initialize_engine
      require_template_library 'yajl'
    end

    def prepare
      @encoder = Yajl::Encoder.new
    end

    def evaluate(scope, locals, &block)
      decorate @encoder.encode(super(scope, locals, &block)), options
    end

    def precompiled_template(locals)
      data.to_str
    end

    # Decorates the +json+ input according to given +options+.
    #
    # json    - The json String to decorate.
    # options - The option Hash to customize the behavior.
    #
    # Returns the decorated String.
    def decorate(json, options)
      callback, variable = options[:callback], options[:variable]
      if callback && variable
        "var #{variable} = #{json}; #{callback}(#{variable});"
      elsif variable
        "var #{variable} = #{json};"
      elsif callback
        "#{callback}(#{json});"
      else
        json
      end
    end
  end

end
