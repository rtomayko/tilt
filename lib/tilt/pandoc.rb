require 'tilt/template'
require 'pandoc-ruby'

module Tilt
  # Pandoc markdown implementation. See:
  # http://pandoc.org/
  class PandocTemplate < Template
    def prepare
      # What about the options?
      @output = PandocRuby.convert(data, to: :html).strip
    end

    def evaluate(scope, locals, &block)
      @output
    end

    def allows_script?
      false
    end
  end
end
