require 'bacon'
require 'tilt'

begin
  describe Tilt::RDocTemplate do
    it "is registered for '.rdoc' files" do
      Tilt['test.rdoc'].should.equal Tilt::RDocTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::RDocTemplate.new { |t| "= Hello World!" }
      template.render.should.equal "<h1>Hello World!</h1>\n"
    end
  end
rescue LoadError => boom
  warn "Tilt::RDocTemplate (disabled)\n"
end
