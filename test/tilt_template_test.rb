require 'contest'
require 'tilt'

class TiltTemplateTest < Test::Unit::TestCase
  test "needs a file or block" do
    assert_raise(ArgumentError) { Tilt::Template.new }
  end

  test "initializing with a file" do
    inst = Tilt::Template.new('foo.erb')
    assert_equal 'foo.erb', inst.file
  end

  test "initializing with a file and line" do
    inst = Tilt::Template.new('foo.erb', 55)
    assert_equal 'foo.erb', inst.file
    assert_equal 55, inst.line
  end

  test "uses correct eval_file" do
    inst = Tilt::Template.new('foo.erb', 55)
    assert_equal 'foo.erb', inst.eval_file
  end

  test "uses a default filename for #eval_file when no file provided" do
    inst = Tilt::Template.new { 'Hi' }
    assert_not_nil inst.eval_file
    assert !inst.eval_file.include?("\n")
  end

  test "calculating template's #basename" do
    inst = Tilt::Template.new('/tmp/templates/foo.html.erb')
    assert_equal 'foo.html.erb', inst.basename
  end

  test "calculating the template's #name" do
    inst = Tilt::Template.new('/tmp/templates/foo.html.erb')
    assert_equal 'foo', inst.name
  end

  test "initializing with a data loading block" do
    Tilt::Template.new { |template| "Hello World!" }
  end

  class InitializingMockTemplate < Tilt::Template
    @@initialized_count = 0
    def self.initialized_count
      @@initialized_count
    end

    def initialize_engine
      @@initialized_count += 1
    end

    def compile!
    end
  end

  test "one-time template engine initialization" do
    assert_nil InitializingMockTemplate.engine_initialized
    assert_equal 0, InitializingMockTemplate.initialized_count

    InitializingMockTemplate.new { "Hello World!" }
    assert InitializingMockTemplate.engine_initialized
    assert_equal 1, InitializingMockTemplate.initialized_count

    InitializingMockTemplate.new { "Hello World!" }
    assert_equal 1, InitializingMockTemplate.initialized_count
  end

  class CompilingMockTemplate < Tilt::Template
    include Test::Unit::Assertions
    def compile!
      assert !data.nil?
      @compiled = true
    end
    def compiled? ; @compiled ; end
  end

  test "raises NotImplementedError when #compile! not defined" do
    inst = Tilt::Template.new { |template| "Hello World!" }
    assert_raise(NotImplementedError) { inst.render }
  end

  test "raises NotImplementedError when #evaluate or #template_source not defined" do
    inst = CompilingMockTemplate.new { |t| "Hello World!" }
    assert_raise(NotImplementedError) { inst.render }
    assert inst.compiled?
  end

  class SimpleMockTemplate < CompilingMockTemplate
    include Test::Unit::Assertions
    def evaluate(scope, locals, &block)
      assert compiled?
      assert !scope.nil?
      assert !locals.nil?
      "<em>#{@data}</em>"
    end
  end

  test "compiles and evaluates the template on #render" do
    inst = SimpleMockTemplate.new { |t| "Hello World!" }
    assert_equal "<em>Hello World!</em>", inst.render
    assert inst.compiled?
  end

  class SourceGeneratingMockTemplate < CompilingMockTemplate
    def template_source
      "foo = [] ; foo << %Q{#{data}} ; foo.join"
    end
  end

  test "template_source with locals" do
    inst = SourceGeneratingMockTemplate.new { |t| 'Hey #{name}!' }
    assert_equal "Hey Joe!", inst.render(Object.new, :name => 'Joe')
    assert inst.compiled?
  end

  class Person
    attr_accessor :name
    def initialize(name)
      @name = name
    end
  end

  test "template_source with an object scope" do
    inst = SourceGeneratingMockTemplate.new { |t| 'Hey #{@name}!' }
    scope = Person.new('Joe')
    assert_equal "Hey Joe!", inst.render(scope)
  end

  test "template_source with a block for yield" do
    inst = SourceGeneratingMockTemplate.new { |t| 'Hey #{yield}!' }
    assert_equal "Hey Joe!", inst.render(Object.new){ 'Joe' }
  end
end
