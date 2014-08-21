require 'tilt/template'
require 'jbuilder'

module Tilt
  # Jbuilder template implementation. See https://github.com/rails/jbuilder.
  class JbuilderTemplate < Template
    self.default_mime_type = 'application/json'
    def prepare; end

    def evaluate(scope, locals, &block)
      return super(scope, locals, &block) if data.respond_to?(:to_str)
      json = Tilt::Jbuilder.new(scope, locals)
      data.call(json)
      json.target!
    end

    def precompiled_preamble(locals)
      return super if locals.include? :json
      "json = Tilt::Jbuilder.new(self)\n#{super}"
    end

    def precompiled_postamble(locals)
      "json.target!"
    end

    def precompiled_template(locals)
      data.to_str
    end
  end

  # Provides `partial!` functionality in a Tilt context.
  class Jbuilder < ::Jbuilder
    def initialize(scope=::Object.new, *args, &block)
      @scope = scope
      super(*args, &block)
    end

    def partial!(name_or_options, locals={})
      case name_or_options
      when ::Hash
        # partial! partial: 'name', locals: { foo: 'bar' }
        options = name_or_options
      else
        # partial! 'name', foo: 'bar'
        options = { :partial => name_or_options, :locals => locals }
        as = locals.delete(:as)
        options[:as] = as if as.present?
        options[:collection] = locals[:collection] if locals.key?(:collection)
      end
      _handle_partial_options options
    end

    def array!(collection = [], *attributes, &block)
      options = attributes.extract_options!
      if options.key?(:partial)
        partial! options[:partial], options.merge(:collection => collection)
      else
        super
      end
    end

    private

    def _handle_partial_options(options)
      options.reverse_merge! :locals => {}
      as = options[:as]

      if as && options.key?(:collection)
        collection = options.delete(:collection) || []
        array!(collection) do |member|
          options[:locals].merge! as => member
          options[:locals].merge! :collection => collection
          _render_partial options
        end
      else
        _render_partial options
      end
    end

    def _render_partial(options)
      locals = options.fetch(:locals)
      locals.merge! :json => self
      file = options.fetch(:partial)

      template = ::Tilt::JbuilderTemplate.new(file)
      template.render(@scope, locals)
    end
  end
end
