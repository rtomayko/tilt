require 'bacon'
require 'tilt'

describe "Tilt::StringTemplate" do
  it "is registered for '.str' files" do
    Tilt['test.str'].should.equal Tilt::StringTemplate
  end

  it "compiles and evaluates the template on #render" do
    template = Tilt::StringTemplate.new { |t| "Hello World!" }
    template.render.should.equal "Hello World!"
  end

  it "supports locals" do
    template = Tilt::StringTemplate.new { 'Hey #{name}!' }
    template.render(Object.new, :name => 'Joe').should.equal "Hey Joe!"
  end

  it "is evaluated in the object scope provided" do
    template = Tilt::StringTemplate.new { 'Hey #{@name}!' }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    template.render(scope).should.equal "Hey Joe!"
  end

  it "evaluates template_source with yield support" do
    template = Tilt::StringTemplate.new { 'Hey #{yield}!' }
    template.render { 'Joe' }.should.equal "Hey Joe!"
  end

  it "renders multiline templates" do
    template = Tilt::StringTemplate.new { "Hello\nWorld!\n" }
    template.render.should.equal "Hello\nWorld!\n"
  end
end
