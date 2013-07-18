require 'tilt/template'
require 'builder'

module Tilt
   # Builder template implementation. See:
  # http://builder.rubyforge.org/
  class BuilderTemplate < Template
    self.default_mime_type = 'text/xml'

    def prepare; end

    def evaluate(scope, locals, &block)
      return super(scope, locals, &block) if data.respond_to?(:to_str)
      xml = ::Builder::XmlMarkup.new(:indent => indent_amount)
      data.call(xml)
      xml.target!
    end

    def precompiled_preamble(locals)
      return super if locals.include? :xml
      "xml = ::Builder::XmlMarkup.new(:indent => #{indent_amount})\n#{super}"
    end

    def precompiled_postamble(locals)
      "xml.target!"
    end

    def precompiled_template(locals)
      data.to_str
    end

    private

    def indent_amount
      options[:indent] || 2
    end

  end
end

