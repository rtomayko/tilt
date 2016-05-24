require 'test_helper'
require 'tilt'

begin
  require 'tilt/rdoc'
  class RstTest < Minitest::Test
    test "is registered for '.rst' files" do
      assert_equal Tilt::RstTemplate, Tilt['test.rst']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::RstTemplate.new { |t| "Hello World!\n============" }
      assert_equal "<h1 id=\"hello-world\">Hello World!</h1>", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::RstTemplate.new { |t| "Hello World!\n============" }
      3.times do
        assert_equal "<h1 id=\"hello-world\">Hello World!</h1>", template.render
      end
    end
  end
rescue LoadError => boom
  warn "Tilt::RstTemplate (disabled) [#{boom}]"
end
