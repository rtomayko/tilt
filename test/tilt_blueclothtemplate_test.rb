require_relative 'test_helper'

begin
  require 'tilt/bluecloth'

  describe 'tilt/bluecloth' do
    it "preparing and evaluating templates on #render" do
      template = Tilt::BlueClothTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1>Hello World!</h1>", template.render
    end

    it "can be rendered more than once" do
      template = Tilt::BlueClothTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>", template.render }
    end

    it "smartypants when :smart is set" do
      template = Tilt::BlueClothTemplate.new(:smartypants => true) { |t|
        "OKAY -- 'Smarty Pants'" }
      assert_equal "<p>OKAY &mdash; &lsquo;Smarty Pants&rsquo;</p>",
        template.render
    end

    it "stripping HTML when :filter_html is set" do
      template = Tilt::BlueClothTemplate.new(:escape_html => true) { |t|
        "HELLO <blink>WORLD</blink>" }
      assert_equal "<p>HELLO &lt;blink>WORLD&lt;/blink></p>", template.render
    end
  end
rescue LoadError
  warn "Tilt::BlueClothTemplate (disabled)"
end
