require 'tilt/template'

module Tilt
  # Sass template implementation. See:
  # http://haml.hamptoncatlin.com/
  #
  # Sass templates do not support object scopes, locals, or yield.
  class SassTemplate < Template
    self.default_mime_type = 'text/css'

    def self.engine_initialized?
      defined? ::Sass::Engine
    end

    def initialize_engine
      require_template_library 'sass'
    end

    def prepare
      if defined? ::Sass::Plugin
        options = ::Sass::Plugin.engine_options(sass_options)
      else
        options = sass_options
      end

      @engine = ::Sass::Engine.new(data, options)
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.render
    end

  private
    def sass_options
      options.merge(:filename => eval_file, :line => line, :syntax => :sass)
    end
  end

  # Sass's new .scss type template implementation.
  class ScssTemplate < SassTemplate
    self.default_mime_type = 'text/css'

  private
    def sass_options
      options.merge(:filename => eval_file, :line => line, :syntax => :scss)
    end
  end

   # Lessscss template implementation. See:
  # http://lesscss.org/
  #
  # Less templates do not support object scopes, locals, or yield.
  class LessTemplate < Template
    self.default_mime_type = 'text/css'

    def self.engine_initialized?
      defined? ::LessJs
    end

    def initialize_engine
      require_template_library 'less-js'
    end

    def prepare; end

    def evaluate(scope, locals, &block)
      LessJs.compile(data)
    end
  end
end

