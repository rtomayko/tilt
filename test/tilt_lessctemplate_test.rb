require 'contest'
require 'tilt'

begin
	Tilt::LesscTemplate.engine_initialized?

  class LesscTemplateTest < Test::Unit::TestCase
    test "is registered for '.lessc' files" do
      assert_equal Tilt::LesscTemplate, Tilt['test.lessc']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::LesscTemplate.new { |t| ".bg { background-color: #0000ff; } \n#main\n { .bg; }\n" }
      assert_equal ".bg {\n  background-color: #0000ff;\n}\n#main {\n  background-color: #0000ff;\n}\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::LesscTemplate.new { |t| ".bg { background-color: #0000ff; } \n#main\n { .bg; }\n" }
      3.times do
				assert_equal ".bg {\n  background-color: #0000ff;\n}\n#main {\n  background-color: #0000ff;\n}\n", template.render
			end
    end
  end

rescue LoadError => boom
  warn "Tilt::LesscTemplate (disabled)\n"
end
