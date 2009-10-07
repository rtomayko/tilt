require 'bacon'
require 'tilt'

begin
  require 'haml'
  require 'sass'

  describe "Tilt::SassTemplate" do
    it "is registered for '.sass' files" do
      Tilt['test.sass'].should.equal Tilt::SassTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::SassTemplate.new { |t| "#main\n  :background-color #0000ff" }
      template.render.should.equal "#main {\n  background-color: #0000ff; }\n"
    end
  end

rescue LoadError => boom
  warn "Tilt::SassTemplate (disabled)\n"
end
