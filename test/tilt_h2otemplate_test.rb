require 'contest'
require 'tilt'

begin
  require 'rubygems'
  require 'h2o'

  class H2oTemplateTest < Test::Unit::TestCase
    test "is registered for '.h2o' files" do
      assert_equal Tilt::H2oTemplate, Tilt['test.h2o']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::H2oTemplate.new { |t| "Hello World!" }
      assert_equal "Hello World!", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::H2oTemplate.new { |t| "Hello World!" }
      3.times { assert_equal "Hello World!", template.render }
    end

    test "passing locals" do
      template = Tilt::H2oTemplate.new { 'Hey {{name}}!' }
      assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
    end

    test "passing more complex locals" do
      template = Tilt::H2oTemplate.new { 'Hey {{person.name}}!' }
      person = { :name => 'Joe' }
      assert_equal "Hey Joe!", template.render(Object.new, :person => person)
    end

    test "passing a block for yield" do
      template =
        Tilt::H2oTemplate.new {
          'Beer is {{ yield }} but Whisky is {{ content }}ter.'
        }
      assert_equal "Beer is wet but Whisky is wetter.",
        template.render({}) { 'wet' }
    end
  end
rescue LoadError => boom
  warn "Tilt::H2oTemplate (disabled)\n"
end
