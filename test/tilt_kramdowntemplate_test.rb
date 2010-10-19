require 'contest'
require 'tilt'

begin
  require 'kramdown'

  class KramdownTemplateTest < Test::Unit::TestCase
    test "preparing and evaluating html templates on #render" do
      template = Tilt::KramdownTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1 id=\"hello-world\">Hello World!</h1>\n", template.render
    end

    test "preparing and evaluating latex templates on #render" do
      template = Tilt::KramdownTemplate.new(:latex => true) { |t| "# Hello World!" }
      assert_equal "\\hypertarget{hello-world}{}\\section{Hello World!}\\label{hello-world}\n\n", template.render
    end

  end
rescue LoadError => boom
  warn "Tilt::KramdownTemplate (disabled)\n"
end
