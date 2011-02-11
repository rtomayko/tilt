require 'contest'
require 'tilt'

begin
  require 'rubygems'
  require 'mustache'

  class MustacheTemplateTest < Test::Unit::TestCase
    test "is registered for '.mustache' files" do
      assert_equal Tilt::MustacheTemplate, Tilt['test.mustache']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::MustacheTemplate.new { |t| "Hello World!" }
      assert_equal "Hello World!", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::MustacheTemplate.new { |t| "Hello World!" }
      3.times { assert_equal "Hello World!", template.render }
    end

    test "passing locals" do
      template = Tilt::MustacheTemplate.new { 'Hey {{name}}!' }
      assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
    end

    test "passing a block for yield" do
      template =
        Tilt::MustacheTemplate.new {
          'Beer is {{ yield }} but Whisky is {{ content }}ter.'
        }
      assert_equal "Beer is wet but Whisky is wetter.",
        template.render({}) { 'wet' }
    end
  end
rescue LoadError => boom
  warn "Tilt::MustacheTemplate (disabled)\n"
end
