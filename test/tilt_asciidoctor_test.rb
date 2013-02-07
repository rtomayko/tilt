require 'contest'
require 'tilt'

begin
  require 'asciidoctor'

  class AsciidoctorTemplateTest < Test::Unit::TestCase
    HTML5_OUTPUT = "\n<div class=\"sect1\">\n  <h2 id=\"_hello_world\">Hello World!</h2>\n  \n  <div class=\"sectionbody\">\n\n  </div>\n  \n</div>\n\n\n"
    DOCBOOK_OUTPUT = "<section id=\"_hello_world\">\n  <title>Hello World!</title>\n\n</section>\n\n"

    test "registered for '.ad' files" do
      assert Tilt.mappings['ad'].include?(Tilt::AsciidoctorTemplate)
    end

    test "registered for '.adoc' files" do
      assert Tilt.mappings['adoc'].include?(Tilt::AsciidoctorTemplate)
    end

    test "registered for '.asciidoc' files" do
      assert Tilt.mappings['asciidoc'].include?(Tilt::AsciidoctorTemplate)
    end

    test "preparing and evaluating html5 templates on #render" do
      template = Tilt::AsciidoctorTemplate.new(:attributes => {"backend" => 'html5'}) { |t| "== Hello World!" } 
      assert_equal HTML5_OUTPUT, template.render
    end

    test "preparing and evaluating docbook templates on #render" do
      template = Tilt::AsciidoctorTemplate.new(:attributes => {"backend" => 'docbook'}) { |t| "== Hello World!" } 
      assert_equal DOCBOOK_OUTPUT, template.render
    end

    test "can be rendered more than once" do
      template = Tilt::AsciidoctorTemplate.new(:attributes => {"backend" => 'html5'}) { |t| "== Hello World!" } 
      3.times { assert_equal HTML5_OUTPUT, template.render }
    end
  end
rescue LoadError => boom
  warn "Tilt::AsciidoctorTemplate (disabled)"
end
