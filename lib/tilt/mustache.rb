require 'tilt/template'
require 'mustache'

module Tilt
  class MustacheTemplate < Template

    class OutPut < Mustache
    end

    def self.engine_initialized?
      defined? ::Mustache
    end

    def initialize_engine
      require_template_library 'mustache'
    end

    def prepare
      @engine ||= OutPut.new
      @engine.template = data
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.render(locals)
    end

  end
end
