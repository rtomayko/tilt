require 'tilt/template'

module Tilt
  # Radius Template
  # http://github.com/jlong/radius/
  class RadiusTemplate < Template
    def self.engine_initialized?
      defined? ::Radius
    end

    def initialize_engine
      require_template_library 'radius'
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      context = Class.new(Radius::Context).new
      context.define_tag("yield") do
        block.call
      end
      locals.each do |tag, value|
        context.define_tag(tag) do
          value
        end
      end
      (class << context; self; end).class_eval do
        define_method :tag_missing do |tag, attr|
          scope.__send__(tag)  # any way to support attr as args?
        end
      end
      options = {:tag_prefix => 'r'}.merge(@options)
      parser = Radius::Parser.new(context, options)
      parser.parse(data)
    end
  end
end
