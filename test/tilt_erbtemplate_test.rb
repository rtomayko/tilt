require_relative 'test_helper'
require 'tilt/erb'
require 'tempfile'

describe 'tilt/erb' do
  it "registered for '.erb' files" do
    assert_includes Tilt.lazy_map['erb'], ['Tilt::ERBTemplate', 'tilt/erb']
  end

  it "registered for '.rhtml' files" do
    assert_includes Tilt.lazy_map['rhtml'], ['Tilt::ERBTemplate', 'tilt/erb']
  end

  it "loading and evaluating templates on #render" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render
  end

  it "can be rendered more than once" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    3.times { assert_equal "Hello World!", template.render }
  end

  it "passing locals" do
    template = Tilt::ERBTemplate.new { 'Hey <%= name %>!' }
    assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
  end

  it "evaluating in an object scope" do
    template = Tilt::ERBTemplate.new { 'Hey <%= @name %>!' }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
  end

  _MockOutputVariableScope = Class.new do
    attr_accessor :exposed_buffer
  end

  it "exposing the buffer to the template by default" do
    verbose = $VERBOSE
    begin
      $VERBOSE = nil
      Tilt::ERBTemplate.default_output_variable = '@_out_buf'
      template = Tilt::ERBTemplate.new { '<% self.exposed_buffer = @_out_buf %>hey' }
      scope = _MockOutputVariableScope.new
      template.render(scope)
      refute_nil scope.exposed_buffer
      assert_equal scope.exposed_buffer, 'hey'
    ensure
      Tilt::ERBTemplate.default_output_variable = '_erbout'
      $VERBOSE = verbose
    end
  end

  it "passing a block for yield" do
    template = Tilt::ERBTemplate.new { 'Hey <%= yield %>!' }
    assert_equal "Hey Joe!", template.render { 'Joe' }
  end

  it "backtrace file and line reporting without locals" do
    data = File.read(__FILE__, :encoding=>'UTF-8').split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 11) { data }
    begin
      template.render
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.grep(/^test\.erb:/).first
      assert line, "Backtrace didn't contain test.erb"
      _file, line, _meth = line.split(":")
      assert_equal '13', line
    end
  end

  it "backtrace file and line reporting with locals" do
    data = File.read(__FILE__, :encoding=>'UTF-8').split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 1) { data }
    begin
      template.render(nil, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, _meth = line.split(":")
      assert_equal 'test.erb', file
      assert_equal '6', line
    end
  end

  it "explicit disabling of trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', 1, :trim => false) { "\n<%= 1 + 1 %>\n" }
    assert_equal "\n2\n", template.render
  end

  it "default stripping trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', 1) { "\n<%= 1 + 1 %>\n" }
    assert_equal "\n2", template.render
  end

  it "stripping trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', 1, :trim => '-') { "\n<%= 1 + 1 -%>\n" }
    assert_equal "\n2", template.render
  end

  it "shorthand whole line syntax trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', :trim => '%') { "\n% if true\nhello\n%end\n" }
    assert_equal "\nhello\n", template.render
  end

  it "using an instance variable as the outvar" do
    template = Tilt::ERBTemplate.new(nil, :outvar => '@buf') { "<%= 1 + 1 %>" }
    scope = Object.new
    scope.instance_variable_set(:@buf, 'original value')
    assert_equal '2', template.render(scope)
    assert_equal 'original value', scope.instance_variable_get(:@buf)
  end
end

describe 'tilt/erb (compiled)' do
  after do
    GC.start
  end

  _Scope = Class.new

  it "compiling template source to a method" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    template.render(_Scope.new)
    method = template.send(:compiled_method, [])
    assert_kind_of UnboundMethod, method
  end

  it "loading and evaluating templates on #render" do
    template = Tilt::ERBTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render(_Scope.new)
    assert_equal "Hello World!", template.render(_Scope.new)
  end

  it "passing locals" do
    template = Tilt::ERBTemplate.new { 'Hey <%= name %>!' }
    assert_equal "Hey Joe!", template.render(_Scope.new, :name => 'Joe')
  end

  it "evaluating in an object scope" do
    template = Tilt::ERBTemplate.new { 'Hey <%= @name %>!' }
    scope = _Scope.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "Hey Joe!", template.render(scope)
    scope.instance_variable_set :@name, 'Jane'
    assert_equal "Hey Jane!", template.render(scope)
  end

  it "passing a block for yield" do
    template = Tilt::ERBTemplate.new { 'Hey <%= yield %>!' }
    assert_equal "Hey Joe!", template.render(_Scope.new) { 'Joe' }
    assert_equal "Hey Jane!", template.render(_Scope.new) { 'Jane' }
  end

  it "backtrace file and line reporting without locals" do
    data = File.read(__FILE__, encoding: 'UTF-8').split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb', 11) { data }
    begin
      template.render(_Scope.new)
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.grep(/^test\.erb:/).first
      assert line, "Backtrace didn't contain test.erb"
      _file, line, _meth = line.split(":")
      assert_equal '13', line
    end
  end

  it "backtrace file and line reporting with locals" do
    data = File.read(__FILE__, encoding: 'UTF-8').split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::ERBTemplate.new('test.erb') { data }
    begin
      template.render(_Scope.new, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, _meth = line.split(":")
      assert_equal 'test.erb', file
      assert_equal '6', line
    end
  end

  it "default stripping trim mode" do
    template = Tilt::ERBTemplate.new('test.erb') { "\n<%= 1 + 1 %>\n" }
    assert_equal "\n2", template.render(_Scope.new)
  end

  it "stripping trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', :trim => '-') { "\n<%= 1 + 1 -%>\n" }
    assert_equal "\n2", template.render(_Scope.new)
  end

  it "shorthand whole line syntax trim mode" do
    template = Tilt::ERBTemplate.new('test.erb', :trim => '%') { "\n% if true\nhello\n%end\n" }
    assert_equal "\nhello\n", template.render(_Scope.new)
  end

  it "encoding with source_encoding" do
    f = Tempfile.open("template")
    f.puts('ふが <%= @hoge %>')
    f.close()
    @hoge = "ほげ"
    erb = Tilt::ERBTemplate.new(f.path){File.read(f.path, encoding: 'UTF-8')}
    3.times { assert_equal 'UTF-8', erb.render(self).encoding.to_s }
    f.delete
  end

  it "encoding with :default_encoding" do
    f = Tempfile.open("template")
    f.puts('ふが <%= @hoge %>')
    f.close()
    @hoge = "ほげ"
    erb = Tilt::ERBTemplate.new(f.path, :default_encoding => 'UTF-8')
    3.times { assert_equal 'UTF-8', erb.render(self).encoding.to_s }
    f.delete
  end

  if RUBY_VERSION >= '2.3'
    it "uses frozen literal strings if :freeze option is used" do
      template = Tilt::ERBTemplate.new(nil, :freeze => true) { |t| %(<%= "".frozen? %>) }
      assert_equal "true", template.render
    end
  end
end

__END__
<html>
<body>
  <h1>Hey <%= name %>!</h1>


  <p><% fail %></p>
</body>
</html>
