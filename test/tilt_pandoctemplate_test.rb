require 'test_helper'
require 'tilt'

begin
  require 'tilt/maruku'

  class PandocTemplateTest < Minitest::Test
    test "registered below Kramdown" do
      %w[md mkd markdown].each do |ext|
        lazy = Tilt.lazy_map[ext]
        kram_idx = lazy.index { |klass, file| klass == 'Tilt::KramdownTemplate' }
        pandoc_idx = lazy.index { |klass, file| klass == 'Tilt::PandocTemplate' }
        assert pandoc_idx > kram_idx,
          "#{pandoc_idx} should be higher than #{kram_idx}"
      end
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::PandocTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1 id=\"hello-world\">Hello World!</h1>", template.render.strip
    end

    test "can be rendered more than once" do
      template = Tilt::PandocTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1 id=\"hello-world\">Hello World!</h1>", template.render.strip }
    end

    test "generates footnotes" do
      template = Tilt::PandocTemplate.new { |t| "Here is an inline note.^[Inlines notes are cool!]" }
      assert_equal "<p>Here is an inline note.<a href=\"#fn1\" class=\"footnoteRef\" id=\"fnref1\"><sup>1</sup></a></p>\n<div class=\"footnotes\">\n<hr />\n<ol>\n<li id=\"fn1\"><p>Inlines notes are cool!<a href=\"#fnref1\">↩</a></p></li>\n</ol>\n</div>", template.render.strip
    end

    test "passes in Pandoc options" do
      # TODO
    end
  end
rescue LoadError => boom
  warn "Tilt::PandocTemplate (disabled)"
end
