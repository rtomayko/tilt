require 'tilt/template'

module Tilt
  # XML Builder Template implementation
  #
  # - http://builder.rubyforge.org/
  #
  # Builder templates support three types of template input: string, file,
  # and block. When the initialize block returns a non-string object that
  # responds to call (Proc), template execution consists of calling the block
  # with a Builder::XmlMarkup instance:
  #
  #     BuilderTemplate.new do
  #       lambda do |xml|
  #         xml.h1 'howdy dudy'
  #         xml.p  'blaahhh'
  #       end
  #     end
  #
  # Builder templates can also be instantiated from a string or file. In that
  # case, the source encoding is determined according to the rules documented
  # in the Tilt README under Encodings. The ruby magic comment line is supported
  # for specifying an alternative encoding.
  #
  # Builder templates always produce utf-8 encoded result strings regardless of
  # the source string / file encoding.
  class BuilderTemplate < Template
    self.default_mime_type = 'text/xml'

    def self.engine_initialized?
      defined? ::Builder
    end

    def initialize_engine
      require_template_library 'builder'
    end

    def prepare
      return if !data.respond_to?(:to_str)
      @source = assign_source_encoding(data.to_str)
    end

    def evaluate(scope, locals, &block)
      return super(scope, locals, &block) if data.respond_to?(:to_str)
      xml = ::Builder::XmlMarkup.new(:indent => 2)
      data.call(xml)
      xml.target!
    end

    def precompiled_template(locals)
      @source
    end

    def precompiled_preamble(locals)
      return super if locals.include? :xml
      "xml = ::Builder::XmlMarkup.new(:indent => 2)\n#{super}"
    end

    def precompiled_postamble(locals)
      "xml.target!"
    end
  end
end

