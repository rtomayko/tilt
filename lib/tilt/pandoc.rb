require 'tilt/template'
require 'pandoc-ruby'

module Tilt
  # Pandoc markdown implementation. See:
  # http://pandoc.org/
  class PandocTemplate < Template
    self.default_mime_type = 'text/html'

    # some options are not recognized by Pandoc
    UNRECOGNIZED_OPTIONS = [:outvar, :context, :fenced_code_blocks]

    # some options are passed via variable parameter
    VARIABLE_OPTIONS = [:lang]

    def tilt_to_pandoc_mapping
      { :smartypants => :smart,
        :escape_html => { :f => 'markdown-raw_html' },
        :commonmark => { :f => 'commonmark' },
        :markdown_strict => { :f => 'markdown_strict' }
      }
    end

    # turn options hash into an array
    # Map tilt options to pandoc options
    # Replace hash keys with value true with symbol for key
    # Remove hash keys with value false
    # Remove unrecognized keys
    # Leave other hash keys untouched
    def pandoc_options
      options.reduce([]) do |sum, (k,v)|
        return sum if UNRECOGNIZED_OPTIONS.include?(k)

        case v
        when true
          sum << (tilt_to_pandoc_mapping[k] || k)
        when false
          sum
        else
          if VARIABLE_OPTIONS.include?(k)
            sum << { "variable" => "#{k}:#{v}" }
          else
            sum << { k => v }
          end
        end
      end
    end

    def prepare
      @engine = PandocRuby.new(data, *pandoc_options)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html.strip
    end

    def allows_script?
      false
    end
  end
end
