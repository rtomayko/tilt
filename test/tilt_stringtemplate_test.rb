require 'contest'
require 'tilt'

class StringTemplateTest < Test::Unit::TestCase
  test "registered for '.str' files" do
    assert_equal Tilt::StringTemplate, Tilt['test.str']
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::StringTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render
  end

  test "passing locals" do
    template = Tilt::StringTemplate.new { 'Hey #{name}!' }
    assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
  end

  test "evaluating in an object scope" do
    template = Tilt::StringTemplate.new { 'Hey #{@name}!' }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
  end

  test "passing a block for yield" do
    template = Tilt::StringTemplate.new { 'Hey #{yield}!' }
    assert_equal "Hey Joe!", template.render { 'Joe' }
  end

  test "multiline templates" do
    template = Tilt::StringTemplate.new { "Hello\nWorld!\n" }
    assert_equal "Hello\nWorld!\n", template.render
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::StringTemplate.new('test.str', 11) { data }
    begin
      template.render
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.str', file
      assert_equal '13', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::StringTemplate.new('test.str', 1) { data }
    begin
      template.render(nil, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.str', file
      assert_equal '6', line
    end
  end
end


class CompiledStringTemplateTest < Test::Unit::TestCase
  def setup
    Tilt.send :remove_const, :CompiledTemplates
    Tilt.send :const_set, :CompiledTemplates, Module.new
    @scope_class = Class.new
    @scope_class.send :include, Tilt::CompiledTemplates
  end

  test "compiling template source to a method" do
    template = Tilt::StringTemplate.new { |t| "Hello World!" }
    template.render
    method_name = "__tilt_#{template.object_id}_#{[].hash}"
    assert Tilt::CompiledTemplates.instance_methods.include?(method_name),
      "CompiledTemplates.instance_methods.include?(#{method_name.inspect})"
    assert @scope_class.new.respond_to?(method_name),
      "scope.respond_to?(#{method_name.inspect})"
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::StringTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render(@scope_class.new)
    assert @scope_class.new.respond_to?("__tilt_#{template.object_id}_#{[].hash}")
  end

  test "passing locals" do
    template = Tilt::StringTemplate.new { 'Hey #{name}!' }
    assert_equal "Hey Joe!", template.render(@scope_class.new, :name => 'Joe')
  end

  test "evaluating in an object scope" do
    template = Tilt::StringTemplate.new { 'Hey #{@name}!' }
    scope = @scope_class.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
  end

  test "passing a block for yield" do
    template = Tilt::StringTemplate.new { 'Hey #{yield}!' }
    assert_equal "Hey Joe!", template.render(@scope_class.new) { 'Joe' }
  end

  test "multiline templates" do
    template = Tilt::StringTemplate.new { "Hello\nWorld!\n" }
    assert_equal "Hello\nWorld!\n", template.render(@scope_class.new)
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::StringTemplate.new('test.str', 11) { data }
    begin
      template.render(@scope_class.new)
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.str', file
      assert_equal '13', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::StringTemplate.new('test.str', 1) { data }
    begin
      template.render(@scope_class.new, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.str', file
      assert_equal '6', line
    end
  end
end

__END__
<html>
<body>
  <h1>Hey #{name}!</h1>


  <p>#{fail}</p>
</body>
</html>
