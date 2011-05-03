require 'contest'
require 'tilt'

begin
  require 'yajl'

  class YajlTemplateTest < Test::Unit::TestCase
    test "is registered for '.yajl' files" do
      assert_equal Tilt::YajlTemplate, Tilt['test.yajl']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::YajlTemplate.new { "{ :integer => 3, :string => 'hello' }" }
      assert_equal '{"integer":3,"string":"hello"}', template.render
    end

    test "can be rendered more than once" do
      template = Tilt::YajlTemplate.new { "{ :integer => 3, :string => 'hello' }" }
      3.times { assert_equal '{"integer":3,"string":"hello"}', template.render }
    end

    test "evaluating ruby code" do
      template = Tilt::YajlTemplate.new { "{ :integer => (3 * 2) }" }
      assert_equal '{"integer":6}', template.render
    end

    test "evaluating in an object scope" do
      template = Tilt::YajlTemplate.new { "{ :string => 'Hey ' + @name + '!' }" }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal '{"string":"Hey Joe!"}', template.render(scope)
    end

    test "passing locals" do
      template = Tilt::YajlTemplate.new { "{ :string => 'Hey ' + name + '!' }" }
      assert_equal '{"string":"Hey Joe!"}', template.render(Object.new, :name => 'Joe')
    end

    test "passing a block for yield" do
      template = Tilt::YajlTemplate.new { "{ :string => 'Hey ' + yield + '!' }" }
      assert_equal '{"string":"Hey Joe!"}', template.render { 'Joe' }
      assert_equal '{"string":"Hey Moe!"}', template.render { 'Moe' }
    end

    test "multiline templates" do
      template = Tilt::YajlTemplate.new { %Q{
        {
          :string   => "hello"
        }
      } }
      assert_equal '{"string":"hello"}', template.render
    end

    test "option callback" do
      options = { :callback => 'foo' }
      template = Tilt::YajlTemplate.new(nil, options) { "{ :string => 'hello' }" }
      assert_equal 'foo({"string":"hello"});', template.render
    end

    test "option variable" do
      options = { :variable => 'output' }
      template = Tilt::YajlTemplate.new(nil, options) { "{ :string => 'hello' }" }
      assert_equal 'var output = {"string":"hello"};', template.render
    end

    test "option callback and variable" do
      options = { :callback => 'foo', :variable => 'output' }
      template = Tilt::YajlTemplate.new(nil, options) { "{ :string => 'hello' }" }
      assert_equal 'var output = {"string":"hello"}; foo(output);', template.render
    end

  end
rescue LoadError => boom
  warn "Tilt::YajlTemplateTest (disabled)\n"
end
