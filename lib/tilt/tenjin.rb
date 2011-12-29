require 'tilt/template'

module Tilt

  class TenjinTemplate < Template

    # This module allows to create a template of the desired class directly.
    # This is needed, since tilt can supply a source directly.
    module EnginePatches

      def new_template
        @templateclass.new(nil, @init_opts_for_template)
      end

      def context_module
        @context_module ||= Module.new{
          include Tenjin::ContextHelper
          extend ContextModule
        }
      end

      def use(x)
        context_module.use(x)
      end

    end

    module ContextModule

      def use(x)
        include(x)
      end

    end


    class << self

      # Sets the engine to use.
      # If the engine is set, no further atempt will be made to load Tenjin.
      attr_writer :engine

      def engine_initialized?
        !@engine.nil?
      end

      # Initializes the tenjin engine.
      def initialize_engine
        return if engine_initialized?
        require 'tenjin'
        self.class_eval "
          class Engine < Tenjin::Engine
            include EnginePatches
          end
        "
        self.engine = Engine.new(:preamble=>true, :postamble=>true)
      end

      # Creates a new engine from the given options.
      # @see http://www.kuwata-lab.com/tenjin/rbtenjin-users-guide.html#dev-engineclass
      def new_engine(options)
        initialize_engine
        Engine.new(options.merge(:preamble=>true, :postamble=>true))
      end

      def engine
        initialize_engine
        return @engine
      end

    end

    attr_reader :context

    def initialize_engine
      self.class.initialize_engine
    end

    def prepare
      e = @options.fetch(:engine, self.class.engine)
      if e.kind_of?(Hash)
        @engine = self.class.new_engine(e)
      elsif defined?(Tenjin::Engine) and e.kind_of? Tenjin::Engine
        if defined? Engine and e.kind_of? Engine
          @engine = e
        else
          @engine = e
          e.extend(EnginePatches)
        end
      end
      @template = @engine.new_template
      @template.convert(self.data,self.file)
    end

    def precompiled_template(_)
      @template.script
    end

    def evaluate(scope, locals, &block)
      method = compiled_method(locals.keys)
      method.bind(scope).call({:_context => @engine.context_module}.update(locals), &block)
    end

    def precompiled_preamble(_)
      ['extend locals[:_context] if locals[:_context];',super].join
    end

  end

end
