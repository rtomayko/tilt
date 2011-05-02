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
      template = Tilt::SassTemplate.new { |t| "#main\n  :background-color #0000f1" }
      assert_equal "#main {\n  background-color: #0000f1; }\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::SassTemplate.new { |t| "#main\n  :background-color #0000f1" }
      3.times { assert_equal "#main {\n  background-color: #0000f1; }\n", template.render }
    end

    test "uses configuration from Sass::Plugin.engine_options" do
      begin
        orig_style = Sass::Plugin.options[:style]
        Sass::Plugin.options[:style] = :compressed
        template = Tilt::SassTemplate.new { |t| "#main\n  :background-color #0000f1" }
        assert_equal "#main{background-color:#0000f1}\n", template.render
      ensure
        Sass::Plugin.options[:style] = orig_style
      end
    end
  end

  class ScssTemplateTest < Test::Unit::TestCase
    test "is registered for '.scss' files" do
      assert_equal Tilt::ScssTemplate, Tilt['test.scss']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::ScssTemplate.new { |t| "#main {\n  background-color: #0000f1;\n}" }
      assert_equal "#main {\n  background-color: #0000f1; }\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::ScssTemplate.new { |t| "#main {\n  background-color: #0000f1;\n}" }
      3.times { assert_equal "#main {\n  background-color: #0000f1; }\n", template.render }
    end
  end

rescue LoadError => boom
  warn "Tilt::SassTemplate (disabled)\n"
end
