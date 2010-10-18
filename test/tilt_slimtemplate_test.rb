require 'contest'
require 'tilt'

begin
  class ::MockError < NameError
  end

  require 'slim'

  class SlimTemplateTest < Test::Unit::TestCase
    test "registered for '.haml' files" do
      assert_equal Tilt::SlimTemplate, Tilt['test.slim']
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::SlimTemplate.new { |t| "p Hello World!" }
      assert_equal "<p>Hello World!</p>", template.render
    end

    test "passing locals" do
      template = Tilt::SlimTemplate.new { "p = 'Hey ' + name + '!'" }
      assert_equal "<p>Hey Joe!</p>", template.render(Object.new, :name => 'Joe')
    end

    test "evaluating in an object scope" do
      template = Tilt::SlimTemplate.new { "p = 'Hey ' + @name + '!'" }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "<p>Hey Joe!</p>", template.render(scope)
    end

    test "passing a block for yield" do
      template = Tilt::SlimTemplate.new { "p = 'Hey ' + yield + '!'" }
      assert_equal "<p>Hey Joe!</p>", template.render { 'Joe' }
    end

    test "backtrace file and line reporting without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?h
      template = Tilt::SlimTemplate.new('test.slim', 10) { data }
      begin
        template.render
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of NameError, boom
        line = boom.backtrace.first
        assert_equal 'test.slim', line.split(":").first
      end
    end

    test "backtrace file and line reporting with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?h
      template = Tilt::SlimTemplate.new('test.slim') { data }
      begin
        res = template.render(Object.new, :name => 'Joe', :foo => 'bar')
      rescue => boom
        assert_kind_of MockError, boom
        line = boom.backtrace.first
        assert_equal 'test.slim', line.split(":").first
      end
    end
  end

  class CompiledSlimTemplateTest < Test::Unit::TestCase
    class Scope
      include Tilt::CompileSite
    end

    test "compiling template source to a method" do
      template = Tilt::SlimTemplate.new { |t| "Hello World!" }
      template.render(Scope.new)
      method_name = template.send(:compiled_method_name, [])
      method_name = method_name.to_sym if Symbol === Kernel.methods.first
      assert Tilt::CompileSite.instance_methods.include?(method_name),
        "CompileSite.instance_methods.include?(#{method_name.inspect})"
      assert Scope.new.respond_to?(method_name),
        "scope.respond_to?(#{method_name.inspect})"
    end

    test "passing locals" do
      template = Tilt::SlimTemplate.new { "p = 'Hey ' + name + '!'" }
      assert_equal "<p>Hey Joe!</p>", template.render(Scope.new, :name => 'Joe')
    end

    test "evaluating in an object scope" do
      template = Tilt::SlimTemplate.new { "p = 'Hey ' + @name + '!'" }
      scope = Scope.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "<p>Hey Joe!</p>", template.render(scope)
    end

    test "passing a block for yield" do
      template = Tilt::SlimTemplate.new { "p = 'Hey ' + yield + '!'" }
      assert_equal "<p>Hey Joe!</p>", template.render(Scope.new) { 'Joe' }
    end

    test "backtrace file and line reporting without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?h
      template = Tilt::SlimTemplate.new('test.slim', 10) { data }
      begin
        template.render(Scope.new)
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of NameError, boom
        line = boom.backtrace.first
        assert_equal 'test.slim', line.split(":").first
      end
    end

    test "backtrace file and line reporting with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?h
      template = Tilt::SlimTemplate.new('test.slim') { data }
      begin
        res = template.render(Scope.new, :name => 'Joe', :foo => 'bar')
      rescue => boom
        assert_kind_of MockError, boom
        line = boom.backtrace.first
        assert_equal 'test.slim', line.split(":").first
      end
    end
  end
rescue LoadError => boom
  warn "Tilt::SlimTemplate (disabled)\n"
end

__END__
html
  body
    h1 = "Hey #{name}"

    = raise MockError

    p we never get here
