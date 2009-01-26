require 'bacon'
require 'tilt'
require 'erb'

describe "Tilt::BuilderTemplate" do
  it "is registered for '.builder' files" do
    Tilt['test.builder'].should.equal Tilt::BuilderTemplate
    Tilt['test.xml.builder'].should.equal Tilt::BuilderTemplate
  end

  it "compiles and evaluates the template on #render" do
    template = Tilt::BuilderTemplate.new { |t| "xml.em 'Hello World!'" }
    template.render.should.equal "<em>Hello World!</em>\n"
  end

  it "supports locals" do
    template = Tilt::BuilderTemplate.new { "xml.em('Hey ' + name + '!')" }
    template.render(Object.new, :name => 'Joe').should.equal "<em>Hey Joe!</em>\n"
  end

  it "is evaluated in the object scope provided" do
    template = Tilt::BuilderTemplate.new { "xml.em('Hey ' + @name + '!')" }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    template.render(scope).should.equal "<em>Hey Joe!</em>\n"
  end

  it "evaluates template_source with yield support" do
    template = Tilt::BuilderTemplate.new { "xml.em('Hey ' + yield + '!')" }
    template.render { 'Joe' }.should.equal "<em>Hey Joe!</em>\n"
  end

  it "calls a block directly when" do
    template =
      Tilt::BuilderTemplate.new do |t|
        lambda { |xml| xml.em('Hey Joe!') }
      end
    template.render.should.equal "<em>Hey Joe!</em>\n"
  end
end
