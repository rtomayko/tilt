require 'bacon'
require 'tilt'

describe Tilt::Template do
  it "raises ArgumentError when a file or block not given" do
    lambda { Tilt::Template.new }.should.raise ArgumentError
  end

  it "can be constructed with a file" do
    inst = Tilt::Template.new('foo.erb')
    inst.file.should.equal 'foo.erb'
  end

  it "can be constructed with a file and line" do
    inst = Tilt::Template.new('foo.erb', 55)
    inst.file.should.equal 'foo.erb'
    inst.line.should.equal 55
  end

  it "uses the filename provided for #eval_file" do
    inst = Tilt::Template.new('foo.erb', 55)
    inst.eval_file.should.equal 'foo.erb'
  end

  it "uses a default filename for #eval_file when no file provided" do
    inst = Tilt::Template.new { 'Hi' }
    inst.eval_file.should.not.be.nil
    inst.eval_file.should.not.include "\n"
  end

  it "responds to #basename with the file's basename" do
    inst = Tilt::Template.new('/tmp/templates/foo.html.erb')
    inst.basename.should.equal 'foo.html.erb'
  end

  it "responds to #name with the file's basename minus file extensions" do
    inst = Tilt::Template.new('/tmp/templates/foo.html.erb')
    inst.name.should.equal 'foo'
  end

  it "can be constructed with a data loading block" do
    lambda {
      Tilt::Template.new { |template| "Hello World!" }
    }.should.not.raise
  end

  it "raises NotImplementedError when #compile! not defined" do
    inst = Tilt::Template.new { |template| "Hello World!" }
    lambda { inst.render }.should.raise NotImplementedError
  end

  class CompilingMockTemplate < Tilt::Template
    def compile!
      data.should.not.be.nil
      @compiled = true
    end
    def compiled? ; @compiled ; end
  end

  it "raises NotImplementedError when #evaluate or #template_source not defined" do
    inst = CompilingMockTemplate.new { |t| "Hello World!" }
    lambda { inst.render }.should.raise NotImplementedError
    inst.should.be.compiled
  end

  class SimpleMockTemplate < CompilingMockTemplate
    def evaluate(scope, locals, &block)
      should.be.compiled
      scope.should.not.be.nil
      locals.should.not.be.nil
      "<em>#{@data}</em>"
    end
  end

  it "compiles and evaluates the template on #render" do
    inst = SimpleMockTemplate.new { |t| "Hello World!" }
    inst.render.should.equal "<em>Hello World!</em>"
    inst.should.be.compiled
  end

  class SourceGeneratingMockTemplate < CompilingMockTemplate
    def template_source
      "foo = [] ; foo << %Q{#{data}} ; foo.join"
    end
  end

  it "evaluates template_source with locals support" do
    inst = SourceGeneratingMockTemplate.new { |t| 'Hey #{name}!' }
    inst.render(Object.new, :name => 'Joe').should.equal "Hey Joe!"
    inst.should.be.compiled
  end

  class Person
    attr_accessor :name
    def initialize(name)
      @name = name
    end
  end

  it "evaluates template_source in the object scope provided" do
    inst = SourceGeneratingMockTemplate.new { |t| 'Hey #{@name}!' }
    scope = Person.new('Joe')
    inst.render(scope).should.equal "Hey Joe!"
  end

  it "evaluates template_source with yield support" do
    inst = SourceGeneratingMockTemplate.new { |t| 'Hey #{yield}!' }
    inst.render(Object.new){ 'Joe' }.should.equal "Hey Joe!"
  end
end
