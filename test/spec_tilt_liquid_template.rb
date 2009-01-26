require 'bacon'
require 'tilt'

begin
  require 'liquid'
  describe "Tilt::LiquidTemplate" do
    it "is registered for '.liquid' files" do
      Tilt['test.liquid'].should.equal Tilt::LiquidTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::LiquidTemplate.new { |t| "Hello World!" }
      template.render.should.equal "Hello World!"
    end

    it "supports locals" do
      template = Tilt::LiquidTemplate.new { "Hey {{ name }}!" }
      template.render(nil, :name => 'Joe').should.equal "Hey Joe!"
    end
  end

rescue LoadError => boom
  warn "Tilt::LiquidTemplate (disabled)\n"
end
