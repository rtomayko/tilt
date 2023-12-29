require 'tilt/template'
require 'commonmarker'

module Tilt
  class CommonMarkerTemplate < Template
    self.default_mime_type = 'text/html'

    PARSE_OPTIONS = [
      :smart,
      :default_info_string,
    ].freeze
    RENDER_OPTIONS = [
      :hardbreaks,
      :github_pre_lang,
      :width,
      :unsafe,
      :escape,
      :sourcepos
    ].freeze
    EXTENSIONS = [
      :strikethrough,
      :tagfilter,
      :table,
      :autolink,
      :tasklist,
      :superscript,
      :header_ids,
      :footnotes,
      :description_lists,
      :front_matter_delimiter,
      :shortcodes,
    ].freeze

    def extensions
      @options.select do |key, _value|
        EXTENSIONS.include?(key)
      end
    end

    def parse_options
      @options.select do |key, _value|
        PARSE_OPTIONS.include?(key)
      end
    end

    def render_options
      @options.select do |key, _value|
        RENDER_OPTIONS.include?(key)
      end
    end

    def prepare
      @engine = nil
      @output = nil
    end

    def evaluate(scope, locals, &block)
      Commonmarker.to_html(data, options: { parse: parse_options, render: render_options, extension: extensions })
    end

    def allows_script?
      false
    end
  end
end
