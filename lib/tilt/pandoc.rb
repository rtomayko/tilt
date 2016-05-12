require 'tilt/template'
require 'pandoc-ruby'

module Tilt
  # Pandoc markdown implementation. See:
  # http://pandoc.org/
  class PandocTemplate < Template
    def prepare
      @output = PandocRuby.convert(data, options_hash, *options_array).strip
    end

    def tilt_to_pandoc_mapping
      { :smartypants => [:smart, true],
        :escape_html => [:f, 'markdown-raw_html']
      }
    end

    def pandoc_optimised_options
      options.inject({}) do |hash, option|
        if tilt_to_pandoc_mapping.has_key?(option[0]) && option[1] === true
          hash[tilt_to_pandoc_mapping[option[0]][0]] = tilt_to_pandoc_mapping[option[0]][1]
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
