require 'contest'
require 'tilt'

begin
  require 'mustache'
  raise LoadError, "mustache version must be > 0.2.2" if !Mustache.respond_to?(:compiled?)

  module Views
    class Foo < Mustache
      attr_reader :foo
    end
  end

  class MustacheTemplateTest < Test::Unit::TestCase
    test "registered for '.mustache' files" do
      assert_equal Tilt::MustacheTemplate, Tilt['test.mustache']
    end

    test "compiling and evaluating templates on #render" do
      template = Tilt::MustacheTemplate.new { |t| "Hello World!" }
      assert_equal "Hello World!", template.render
    end

    test "passing locals" do
      template = Tilt::MustacheTemplate.new { "<p>Hey {{name}}!</p>" }
      assert_equal "<p>Hey Joe!</p>", template.render(nil, :name => 'Joe')
    end

    test "passing a block for yield" do
      template = Tilt::MustacheTemplate.new { "<p>Hey {{yield}}!</p>" }
      assert_equal "<p>Hey Joe!</p>", template.render { 'Joe' }
    end

    test "locating views defined at the top-level" do
      template = Tilt::MustacheTemplate.new('foo.mustache') { "<p>Hey {{foo}}!</p>" }
      template.compile
      assert_equal Views::Foo, template.engine
    end

    module Bar
      module Views
        class Bizzle < Mustache
        end
      end
    end

    test "locating views defined in a custom namespace" do
      template = Tilt::MustacheTemplate.new('bizzle.mustache', :namespace => Bar) { "<p>Hello World!</p>" }
      template.compile
      assert_equal Bar::Views::Bizzle, template.engine
      assert_equal "<p>Hello World!</p>", template.render
    end

    test "copying instance variables from scope object" do
      template = Tilt::MustacheTemplate.new('foo.mustache') { "<p>Hey {{foo}}!</p>" }
      scope = Object.new
      scope.instance_variable_set(:@foo, 'Jane!')
      assert_equal "<p>Hey Jane!!</p>", template.render(scope)
    end
  end

rescue LoadError => boom
  warn "Tilt::MustacheTemplate (disabled)\n"
end
