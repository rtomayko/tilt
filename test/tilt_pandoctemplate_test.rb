require_relative 'test_helper'

begin
  require 'tilt/pandoc'

  describe 'tilt/pandoc' do
    it "preparing and evaluating templates on #render" do
      template = Tilt::PandocTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1 id=\"hello-world\">Hello World!</h1>", template.render
    end

    it "can be rendered more than once" do
      template = Tilt::PandocTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1 id=\"hello-world\">Hello World!</h1>", template.render }
    end

    it "smartypants when :smartypants is set" do
      with_utf8_default_encoding do
        template = Tilt::PandocTemplate.new(:smartypants => true) { |t| "OKAY -- 'Smarty Pants'" }
        assert_equal "<p>OKAY – ‘Smarty Pants’</p>", template.render
      end
    end

    it "stripping HTML when :escape_html is set" do
      template = Tilt::PandocTemplate.new(:escape_html => true) { |t| "HELLO <blink>WORLD</blink>" }
      assert_equal "<p>HELLO &lt;blink&gt;WORLD&lt;/blink&gt;</p>", template.render
    end

    # Pandoc has tons of additional markdown features (see http://pandoc.org/README.html#pandocs-markdown).
    # The it for footnotes should be seen as a general representation for all of them.
    # use markdown_strict => true to disable additional markdown features
    describe "passing in Pandoc options" do
      it "generates footnotes" do
        with_utf8_default_encoding do
          template = Tilt::PandocTemplate.new { |t| "Here is an inline note.^[Inlines notes are cool!]" }
          result = template.render
          assert_match "Here is an inline note", result
          assert_match "Inlines notes are cool!", result
        end
      end

      it "doesn't generate footnotes with markdown_strict option" do
        template = Tilt::PandocTemplate.new(:markdown_strict => true) { |t| "Here is an inline note.^[Inlines notes are cool!]" }
        assert_equal "<p>Here is an inline note.^[Inlines notes are cool!]</p>", template.render
      end

      it "doesn't generate footnotes with commonmark option" do
        template = Tilt::PandocTemplate.new(:commonmark => true) { |t| "Here is an inline note.^[Inlines notes are cool!]" }
        assert_equal "<p>Here is an inline note.^[Inlines notes are cool!]</p>", template.render
      end

      it "accepts arguments with values (e.g. :id_prefix => 'xyz')" do
        # Table of contents isn't on by default
        template = Tilt::PandocTemplate.new { |t| "# This is a heading" }
        assert_equal "<h1 id=\"this-is-a-heading\">This is a heading</h1>", template.render

        # But it can be activated
        template = Tilt::PandocTemplate.new(:id_prefix => 'it-') { |t| "# This is a heading" }
        assert_equal "<h1 id=\"it-this-is-a-heading\">This is a heading</h1>", template.render
      end

      it "requires arguments without value (e.g. --standalone) to be passed as hash keys (:standalone => true)" do
        template = Tilt::PandocTemplate.new(:standalone => true) { |t| "# This is a heading" }
        assert_match(/^<!DOCTYPE html.*<h1 id="this-is-a-heading">This is a heading<\/h1>.*<\/html>$/m, template.render)
      end
    end
  end
rescue LoadError
  warn "Tilt::PandocTemplate (disabled)"
end
