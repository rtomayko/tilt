require 'tilt/template'
require 'pandoc-ruby'

module Tilt
  # Pandoc markdown implementation. See:
  # http://pandoc.org/
  class PandocTemplate < Template
    def prepare
      @output = PandocRuby.convert(data, {:to => :html}, *options).strip
    end

    def evaluate(scope, locals, &block)
      @output
    end

    def allows_script?
      false
    end
  end
end
