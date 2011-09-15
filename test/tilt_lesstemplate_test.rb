require 'contest'
require 'tilt'

begin
  require 'pathname'
  require 'less'

  class LessTemplateTest < Test::Unit::TestCase
    test "is registered for '.less' files" do
      assert_equal Tilt::LessTemplate, Tilt['test.less']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::LessTemplate.new { |t| ".bg { background-color: #0000ff; } \n#main\n { .bg; }\n" }
      assert_equal ".bg {\n  background-color: #0000ff;\n}\n#main {\n  background-color: #0000ff;\n}\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::LessTemplate.new { |t| ".bg { background-color: #0000ff; } \n#main\n { .bg; }\n" }
      3.times { assert_equal ".bg {\n  background-color: #0000ff;\n}\n#main {\n  background-color: #0000ff;\n}\n", template.render }
    end

    test "can be passed a load path" do
      template = Tilt::LessTemplate.new({
        :paths => [Pathname(__FILE__).dirname]
      }) {
        <<-EOLESS
        @import 'tilt_lesstemplate_test.less';
        .bg {background-color: @text-color;}
        EOLESS
      }
      assert_equal ".bg {\n  background-color: pink;\n}\n", template.render
    end
  end

rescue LoadError => boom
  warn "Tilt::LessTemplate (disabled)"
end
