require_relative 'test_helper'

begin
  require 'tilt/commonmarker'

  describe 'tilt/commonmarker' do
    it "preparing and evaluating templates on #render" do
      template = Tilt::CommonMarkerTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1>Hello World!</h1>\n", template.render
    end

    it "can be rendered more than once" do
      template = Tilt::CommonMarkerTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>\n", template.render }
    end

    it "smartypants when :smartypants is set" do
      template = Tilt::CommonMarkerTemplate.new(smart: true) do |t|
        "OKAY -- 'Smarty Pants'"
      end
      assert_match('<p>OKAY – ‘Smarty Pants’</p>', template.render)
    end

    it 'Renders unsafe HTML when :unsafe is set' do
      template = Tilt::CommonMarkerTemplate.new(unsafe: true) do |_t|
        <<~MARKDOWN
          <div class="alert alert-info full-width">
            <h5 class="card-title">TL;DR</h5>
            <p>This is an unsafe HTML block</p>
          </div>

          And then some **other** Markdown
        MARKDOWN
      end

      expected = <<~EXPECTED_HTML
        <div class="alert alert-info full-width">
          <h5 class="card-title">TL;DR</h5>
          <p>This is an unsafe HTML block</p>
        </div>
        <p>And then some <strong>other</strong> Markdown</p>
      EXPECTED_HTML

      assert_match(expected, template.render)
    end

    it "autolinking when :autolink is set" do
      template = Tilt::CommonMarkerTemplate.new(autolink: true) do |t|
        "https://example.com"
      end
      assert_match('<a href="https://example.com">https://example.com</a>', template.render)
    end
  end
rescue LoadError
  warn "Tilt::CommonMarkerTemplate (disabled)"
end
