require 'contest'
require 'tilt'

begin
  class HTMLTemplateTest < Test::Unit::TestCase
    test "is registered for '.html' files" do
      assert_equal Tilt::HTMLTemplate, Tilt['test.html']
    end

    test "compiling and evaluating the template with #render" do
      template = Tilt::HTMLTemplate.new { |t| "<html><head></head><body>Hello World!</body></html>" }
      assert_equal "<html><head></head><body>Hello World!</body></html>", template.render
    end
  end
rescue LoadError => boom
  warn "Tilt::HTMLTemplate (disabled)\n"
end

