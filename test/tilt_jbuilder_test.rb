require 'test_helper'
require 'tilt'

begin
  require 'tilt/jbuilder'
  class JbuilderTemplateTest < Minitest::Test
    test "registered for '.jbuilder' files" do
      assert_equal Tilt::JbuilderTemplate, Tilt['test.jbuilder']
      assert_equal Tilt::JbuilderTemplate, Tilt['test.json.jbuilder']
    end

    test "preparing and evaluating the template on #render" do
      template = Tilt::JbuilderTemplate.new { "json.welcome 'Hello World!'" }
      assert_equal '{"welcome":"Hello World!"}', template.render
    end

    test "can be rendered more than once" do
      template = Tilt::JbuilderTemplate.new { "json.house 'Stark'" }
      3.times { assert_equal '{"house":"Stark"}', template.render }
    end

    test "passing locals" do
      template = Tilt::JbuilderTemplate.new { "json.name name" }
      assert_equal '{"name":"Ned"}', template.render(Object.new, :name => 'Ned')
    end

    test "evaluating in an object scope" do
      template = Tilt::JbuilderTemplate.new { "json.words @words" }
      scope = Object.new
      scope.instance_variable_set :@words, 'Winter is Coming.'
      assert_equal '{"words":"Winter is Coming."}', template.render(scope)
    end

    test "passing a block for yield" do
      template = Tilt::JbuilderTemplate.new { "json.bannermen yield" }
      3.times { assert_equal '{"bannermen":10000}', template.render { 10000 }}
    end

    test "block style templates" do
      template =
        Tilt::JbuilderTemplate.new do |t|
          lambda { |json| json.battle('Blackwater') }
        end
      assert_equal '{"battle":"Blackwater"}', template.render
    end

    test "render partials with partial!" do
      template = Tilt::JbuilderTemplate.new {
        "json.partial! 'test/jbuilder/_partial.jbuilder'"
      }
      assert_equal '{"foo":"bar"}', template.render
    end

    test "render partials with locals" do
      template = Tilt::JbuilderTemplate.new {
        "json.partial! 'test/jbuilder/_locals.jbuilder', thing: thing"
      }
      assert_equal '{"thing":1}', template.render(Object.new, :thing => 1)
    end

    test "render partials for a collection" do
      template = Tilt::JbuilderTemplate.new {
        "json.things things, partial: 'test/jbuilder/_locals.jbuilder', as: :thing"
      }
      assert_equal  '{"things":[{"thing":1},{"thing":2}]}',
                    template.render(Object.new, :things => [1,2])
    end

    test "render an array with a partial and a passed-through scope" do
      template = Tilt::JbuilderTemplate.new {
        "json.array! @beers, partial: 'test/jbuilder/_scope.jbuilder', as: :beer"
      }
      scope = Object.new
      scope.instance_variable_set :@beers, ['Pabst', 'Coors']
      scope.instance_variable_set :@beer, 'good'
      assert_equal '[{"beer":"good"},{"beer":"good"}]', template.render(scope)
    end

    test "render nested json templates" do
      inner_temp = Tilt::JbuilderTemplate.new { "json.a ['nice', 'day']" }
      outer_temp = Tilt::JbuilderTemplate.new { "json.have { yield }" }
      scope = Object.new
      locals = { :json => Tilt::Jbuilder.new }
      rendered = outer_temp.render(scope, locals) {
        inner_temp.render(scope, locals)
      }
      assert_equal  '{"have":{"a":["nice","day"]}}', rendered
    end

  end
rescue LoadError
  warn "Tilt::JbuilderTemplate (disabled)"
end
