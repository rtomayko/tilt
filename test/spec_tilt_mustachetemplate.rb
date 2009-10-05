require 'bacon'
require 'tilt'

begin
  require 'mustache'
  describe "Tilt::MustacheTemplate" do
    it "is registered for '.mustache' files" do
      Tilt['test.mustache'].should.equal Tilt::MustacheTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::MustacheTemplate.new { |t| "Hello World!" }
      template.render.should.equal "Hello World!"
    end

    it "supports locals" do
      template = Tilt::MustacheTemplate.new { "<p>Hey {{name}}!</p>" }
      template.render(nil, :name => 'Joe').should.equal "<p>Hey Joe!</p>"
    end

    it "evaluates template_source with yield support" do
      template = Tilt::MustacheTemplate.new { "<p>Hey {{yield}}!</p>" }
      template.render { 'Joe' }.should.equal "<p>Hey Joe!</p>"
    end
  end

rescue LoadError => boom
  warn "Tilt::MustacheTemplate (disabled)\n"
end

__END__
<html>
 <body>
  <h1>Hey {{name}}</h1>

  <p>{{fail}}</p>
  <p>we never get here</p>
 </body>
</html>
