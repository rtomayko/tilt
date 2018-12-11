require 'tilt/template'
require 'hamdown'

# Hamdown see: https://github.com/inem/hamdown
module Tilt
  # Hamdown implementation for Hamdown see:
  # https://github.com/inem/hamdown
  #
  # Hamdown is an open source, pure-Ruby processor for
  # converting Hamdown documents or strings into HTML 5 format
  class HamdownTemplate < Template
    self.default_mime_type = 'text/html'

    def prepare
      options[:header_footer] = false if options[:header_footer].nil?
    end

    def evaluate(scope, locals, &block)
      @output ||= Hamdown::Engine.perform(data, options, &block)
    end

    def allows_script?
      false
    end
  end
end
