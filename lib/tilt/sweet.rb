require 'tilt/template'

module Tilt
  # Sweet template implementation.
  class SweetTemplate < Template
    self.default_mime_type = 'text/html'

    def self.engine_initialized?
      defined? ::SweetLang
    end

    def initialize_engine
      require_template_library 'sweet'
    end

    def prepare
      @engine = ::SweetLang::Sweet.new
    end

    def precompiled_template(locals)
      @engine.engine( data )
    end

  end
end

