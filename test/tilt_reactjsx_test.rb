require 'test_helper'
require 'tilt'

begin
  require 'tilt/reactjsx'

  class ReactJSXTemplateTest < Minitest::Test
    def setup
      @jsx = <<-EOF
        /** @jsx React.DOM */
        React.renderComponent(
          <h1>Hello, world!</h1>,
          document.getElementById('example')
        );
      EOF

      @js = <<-EOF
        /** @jsx React.DOM */
        React.renderComponent(
          React.DOM.h1(null, \"Hello, world!\"),
          document.getElementById('example')
        );
      EOF
    end

    test "is registered for '.jsx' files" do
      assert_equal Tilt::ReactJSXTemplate, Tilt['test.jsx']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::ReactJSXTemplate.new { @jsx }
      assert_match @js, template.render
    end

    test "can be rendered more than once" do
      template = Tilt::ReactJSXTemplate.new { @jsx }
      3.times { assert_match @js, template.render }
    end
  end
rescue LoadError => boom
  warn "Tilt::ReactJSXTemplate (disabled)"
end
