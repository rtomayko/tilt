require 'contest'
require 'tilt'

begin
  require 'haml'
  require 'sass'

  class SassTemplateTest < Test::Unit::TestCase
    test "is registered for '.sass' files" do
      assert_equal Tilt::SassTemplate, Tilt['test.sass']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::SassTemplate.new { |t| "#main\n  :background-color #0000ff" }
      assert_equal "#main {\n  background-color: #0000ff; }\n", template.render
    end
  end

rescue LoadError => boom
  warn "Tilt::SassTemplate (disabled)\n"
end
