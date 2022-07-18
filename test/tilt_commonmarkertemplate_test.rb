require 'test_helper'
require 'tilt'

begin
  require 'tilt/commonmarker'

  class CommonMarkerTemplateTest < Minitest::Test
    test "preparing and evaluating templates on #render" do
      template = Tilt::CommonMarkerTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1>Hello World!</h1>\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::CommonMarkerTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>\n", template.render }
    end

    test "smartypants when :smartypants is set" do
      template = Tilt::CommonMarkerTemplate.new(:smartypants => true) do |t|
        "OKAY -- 'Smarty Pants'"
      end
      assert_match('<p>OKAY – ‘Smarty Pants’</p>', template.render)
    end

    test 'Renders unsafe HTML when :UNSAFE is set' do
      template = Tilt::CommonMarkerTemplate.new(UNSAFE: true) do |_t|
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
  end
rescue LoadError
  warn "Tilt::CommonMarkerTemplate (disabled)"
end
