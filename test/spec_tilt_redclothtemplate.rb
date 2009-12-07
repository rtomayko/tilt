require 'bacon'
require 'tilt'

begin
  require 'redcloth'

  describe Tilt::RedClothTemplate do
    it "is registered for '.textile' files" do
      Tilt['test.textile'].should.equal Tilt::RedClothTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::RedClothTemplate.new { |t| "h1. Hello World!" }
      template.render.should.equal "<h1>Hello World!</h1>"
    end

  end
rescue LoadError => boom
  warn "Tilt::RedClothTemplate (disabled)\n"
end
