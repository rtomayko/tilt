require 'contest'
require 'tilt'
require 'erb'

class ERBTemplateTest < Test::Unit::TestCase
  test "registered for '.erb' files" do
    assert_equal Tilt::ERBTemplate, Tilt['test.erb']
    assert_equal Tilt::ERBTemplate, Tilt['test.html.erb']
  end

  test "registered for '.rhtml' files" do
    assert_equal Tilt::ERBTemplate, Tilt['test.rhtml']
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render
  end

  test "passing locals" do
    template = Tilt::ERBTemplate.new { 'Hey <%= name %>!' }
    assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
  end

  test "evaluating in an object scope" do
    template = Tilt::ERBTemplate.new { 'Hey <%= @name %>!' }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
  end

  test "passing a block for yield" do
    template = Tilt::ERBTemplate.new { 'Hey <%= yield %>!' }
    assert_equal "Hey Joe!", template.render { 'Joe' }
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 11) { data }
    begin
      template.render
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.erb', file
      assert_equal '13', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 1) { data }
    begin
      template.render(nil, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.erb', file
      assert_equal '6', line
    end
  end

  test "default non-stripping trim mode" do
    template = Tilt.new('test.erb', 1) { "\n<%= 1 + 1 %>\n" }
    assert_equal "\n2\n", template.render
  end

  test "stripping trim mode" do
    template = Tilt.new('test.erb', 1, :trim => '-') { "\n<%= 1 + 1 -%>\n" }
    assert_equal "\n2", template.render
  end

  test "shorthand whole line syntax trim mode" do
    template = Tilt.new('test.erb', 1, :trim => '%') { "\n% if true\nhello\n%end\n" }
    assert_equal "\nhello\n", template.render
  end
end

class CompiledERBTemplateTest < Test::Unit::TestCase
  def setup
    @compile_site = Module.new
    @scope_class = Class.new
    @scope_class.send :include, @compile_site
  end

  test "compiling template source to a method" do
    template = Tilt::ERBTemplate.new(nil, 1, {}, @compile_site) { |t| "Hello World!" }
    template.render(@scope_class.new)
    method_name = "__tilt_#{template.object_id}_#{[].hash}"
    method_name = method_name.to_sym if Symbol === Kernel.methods.first
    assert @compile_site.instance_methods.include?(method_name),
      "compile_site.instance_methods.include?(#{method_name.inspect})"
    assert @scope_class.new.respond_to?(method_name),
      "scope.respond_to?(#{method_name.inspect})"
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::ERBTemplate.new(nil, 1, {}, @compile_site) { |t| "Hello World!" }
    assert_equal "Hello World!", template.render(@scope_class.new)
    assert_equal "Hello World!", template.render(@scope_class.new)
  end

  test "passing locals" do
    template = Tilt::ERBTemplate.new(nil, 1, {}, @compile_site) { 'Hey <%= name %>!' }
    assert_equal "Hey Joe!", template.render(@scope_class.new, :name => 'Joe')
  end

  test "evaluating in an object scope" do
    template = Tilt::ERBTemplate.new(nil, 1, {}, @compile_site) { 'Hey <%= @name %>!' }
    scope = @scope_class.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
    scope.instance_variable_set :@name, 'Jane'
    assert_equal "Hey Jane!", template.render(scope)
  end

  test "passing a block for yield" do
    template = Tilt::ERBTemplate.new(nil, 1, {}, @compile_site) { 'Hey <%= yield %>!' }
    assert_equal "Hey Joe!", template.render(@scope_class.new) { 'Joe' }
    assert_equal "Hey Jane!", template.render(@scope_class.new) { 'Jane' }
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 11, @compile_site) { data }
    begin
      template.render(@scope_class.new)
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.erb', file
      assert_equal '13', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 1, @compile_site) { data }
    begin
      template.render(@scope_class.new, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.erb', file
      assert_equal '6', line
    end
  end

  test "default non-stripping trim mode" do
    template = Tilt.new('test.erb', 1) { "\n<%= 1 + 1 %>\n" }
    assert_equal "\n2\n", template.render(@scope_class.new)
  end

  test "stripping trim mode" do
    template = Tilt.new('test.erb', 1, :trim => '-') { "\n<%= 1 + 1 -%>\n" }
    assert_equal "\n2", template.render(@scope_class.new)
  end

  test "shorthand whole line syntax trim mode" do
    template = Tilt.new('test.erb', 1, :trim => '%') { "\n% if true\nhello\n%end\n" }
    assert_equal "\nhello\n", template.render(@scope_class.new)
  end
end

__END__
<html>
<body>
  <h1>Hey <%= name %>!</h1>


  <p><% fail %></p>
</body>
</html>
