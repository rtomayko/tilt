require 'bacon'
require 'tilt'

begin
  require 'rdiscount'

  describe Tilt::RDiscountTemplate do
    it "is registered for '.markdown' files" do
      Tilt['test.markdown'].should.equal Tilt::RDiscountTemplate
    end

    it "is registered for '.md' files" do
      Tilt['test.md'].should.equal Tilt::RDiscountTemplate
    end

    it "is registered for '.mkd' files" do
      Tilt['test.mkd'].should.equal Tilt::RDiscountTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::RDiscountTemplate.new { |t| "# Hello World!" }
      template.render.should.equal "<h1>Hello World!</h1>\n"
    end

    it "uses smartypants style punctuation replacements when :smart is set" do
      template = Tilt::RDiscountTemplate.new(nil, :smart => true) { |t|
        "OKAY -- 'Smarty Pants'" }
      template.render.should.equal \
        "<p>OKAY &mdash; &lsquo;Smarty Pants&rsquo;</p>\n"
    end

    it "strips HTML when :filter_html is set" do
      template = Tilt::RDiscountTemplate.new(nil, :filter_html => true) { |t|
        "HELLO <blink>WORLD</blink>" }
      template.render.should.equal \
        "<p>HELLO &lt;blink>WORLD&lt;/blink></p>\n"
    end
  end
rescue LoadError => boom
  warn "Tilt::RDiscountTemplate (disabled)\n"
end
