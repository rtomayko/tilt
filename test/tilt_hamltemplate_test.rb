require 'contest'
require 'tilt'

begin
  class ::MockError < NameError
  end

  require 'haml'

  class HamlTemplateTest < Test::Unit::TestCase
    test "registered for '.haml' files" do
      assert_equal Tilt::HamlTemplate, Tilt['test.haml']
    end

    test "compiling and evaluating templates on #render" do
      template = Tilt::HamlTemplate.new { |t| "%p Hello World!" }
      assert_equal "<p>Hello World!</p>\n", template.render
    end

    test "passing locals" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + name + '!'" }
      assert_equal "<p>Hey Joe!</p>\n", template.render(Object.new, :name => 'Joe')
    end

    test "evaluating in an object scope" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + @name + '!'" }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "<p>Hey Joe!</p>\n", template.render(scope)
    end

    test "passing a block for yield" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + yield + '!'" }
      assert_equal "<p>Hey Joe!</p>\n", template.render { 'Joe' }
    end

    test "backtrace file and line reporting without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?%
      template = Tilt::HamlTemplate.new('test.haml', 10) { data }
      begin
        template.render
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of NameError, boom
        line = boom.backtrace.first
        file, line, meth = line.split(":")
        assert_equal 'test.haml', file
        assert_equal '12', line
      end
    end

    test "backtrace file and line reporting with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?%
      template = Tilt::HamlTemplate.new('test.haml') { data }
      begin
        res = template.render(Object.new, :name => 'Joe', :foo => 'bar')
      rescue => boom
        assert_kind_of MockError, boom
        line = boom.backtrace.first
        file, line, meth = line.split(":")
        assert_equal 'test.haml', file
        assert_equal '5', line
      end
    end
  end

rescue LoadError => boom
  warn "Tilt::HamlTemplate (disabled)\n"
end

__END__
%html
  %body
    %h1= "Hey #{name}"

    = raise MockError

    %p we never get here
