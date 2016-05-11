require 'tilt/template'
require 'pandoc-ruby'

module Tilt
  # Pandoc markdown implementation. See:
  # http://pandoc.org/
  class PandocTemplate < Template
    def prepare
      @output = PandocRuby.convert(data, options_hash.merge(
                                           {:to => :html}
                                         ), *options_array
                                  ).strip
    end

    def tilt_to_pandoc_mapping
      { :smartypants => :smart,
        :escape_html => :markdown_strict
      }
    end

    def options_array
      options.map do |option|
        tilt_to_pandoc_mapping[option[0]] || option[0] if option[1] === true
      end.compact
    end

    def options_hash
      options.inject({}) do |hash, option|
        hash[option[0]] = option[1] unless option[1] === true
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
