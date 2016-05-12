require 'tilt/template'
require 'pandoc-ruby'

module Tilt
  # Pandoc markdown implementation. See:
  # http://pandoc.org/
  class PandocTemplate < Template
    def prepare
      @output = PandocRuby.convert(data, options_hash, *options_array).strip
    end

    def pandoc_optimised_options
      options.inject({}) do |hash, option|
        if option[0] == :smartypants
          hash[:smart] = true if option[1] === true
        elsif option[0] == :escape_html
          hash[:f] = 'markdown-raw_html' if option[1] === true
        else
          hash[option[0]] = option[1]
        end

        hash
      end.merge({:to => :html})
    end

    def options_array
      pandoc_optimised_options.map do |option|
        option[0] if option[1] === true
      end.compact
    end

    def options_hash
      pandoc_optimised_options.inject({}) do |hash, option|
        # next if option[1] === true
        # next if option[1] === false
        hash[option[0]] = option[1] unless option[1] === true or option[1] === false
        hash
      end
    end

    def evaluate(scope, locals, &block)
      @output
    end

    def allows_script?
      false
    end
  end
end
