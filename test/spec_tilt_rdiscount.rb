require 'bacon'
require 'tilt'

begin
  require 'rdiscount'
  describe "Tilt::RDiscountTemplate" do
    it "is registered for '.markdown' files" do
      Tilt['test.markdown'].should.equal Tilt::RDiscountTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::RDiscountTemplate.new { |t| "# Hello World!" }
      template.render.should.equal "<h1>Hello World!</h1>\n"
    end
  end
rescue LoadError => boom
  warn "Tilt::RDiscountTemplate (disabled)\n"
end
