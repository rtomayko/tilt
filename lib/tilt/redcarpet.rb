require 'tilt/template'
require 'redcarpet'

module Tilt
  class RedcarpetTemplate < Template
    self.default_mime_type = 'text/html'

    ALIAS = {
      :escape_html => :filter_html,
      :smartypants => :smart
    }

    def generate_renderer
      renderer = options.delete(:renderer) || ::Redcarpet::Render::HTML.new(options)
      return renderer unless options.delete(:smartypants)
      return renderer if renderer.is_a?(Class) && renderer <= ::Redcarpet::Render::SmartyPants

      if renderer == ::Redcarpet::Render::XHTML
        ::Redcarpet::Render::SmartyHTML.new(:xhtml => true)
      elsif renderer == ::Redcarpet::Render::HTML
        ::Redcarpet::Render::SmartyHTML
      elsif renderer.is_a? Class
        Class.new(renderer) { include ::Redcarpet::Render::SmartyPants }
      else
        renderer.extend ::Redcarpet::Render::SmartyPants
      end
    end

    def prepare
      ALIAS.each do |opt, aka|
        next if options.key? opt or not options.key? aka
        options[opt] = options.delete(aka)
      end

      # only raise an exception if someone is trying to enable :escape_html
      options.delete(:escape_html) unless options[:escape_html]

      @engine = ::Redcarpet::Markdown.new(generate_renderer, options)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.render(data)
    end

    def allows_script?
      false
    end
  end
end

