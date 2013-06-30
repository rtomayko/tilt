require 'tilt/template'
require 'handlebars'

module Tilt

  # Handlebars.rb template implementation. See:
  # https://github.com/cowboyd/handlebars.rb
  # and http://handlebarsjs.com
  #
  # Handlebars is a logic-less template rendered with JavaScript.
  # Handlebars.rb is a Ruby wrapper around Handlebars, that allows
  # Handlebars templates to be rendered server side.
  #
  class HandlebarsTemplate < Template
    def initialize_engine
      @context = ::Handlebars::Context.new
    end     

    def prepare
      @context = ::Handlebars::Context.new
          @template = @context.compile(data)
      end

    def evaluate(scope, locals = {}, &block)
      # Based on LiquidTemplate
      locals = locals.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }
      if scope.respond_to?(:to_h)
        scope  = scope.to_h.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }
        locals = scope.merge(locals)
      else
        scope.instance_variables.each {|var| locals[var.to_s.delete("@")] = scope.instance_variable_get(var) }
      end

      locals['yield'] = block.nil? ? '' : yield
      locals['content'] = locals['yield']

      @template.call(locals);
    end

    def register_helper(name, &fn)
      @context.register_helper(name, &fn)
    end

    def register_partial(*args)
      @context.register_partial(*args)
    end

    def partial_missing(&fn)
      @context.partial_missing(&fn)
    end

    def allows_script?
      false
    end
  end
end


