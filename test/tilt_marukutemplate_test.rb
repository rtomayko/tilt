require 'contest'
require 'tilt'

begin
  require 'maruku'

  class MarukuTemplateTest < Test::Unit::TestCase
    setup do
      Tilt.register('markdown', Tilt::MarukuTemplate)
      Tilt.register('md', Tilt::MarukuTemplate)
      Tilt.register('mkd', Tilt::MarukuTemplate)
    end

    teardown do
      # Need to revert to RDiscount, otherwise the RDiscount test will fail
      Tilt.register('markdown', Tilt::RDiscountTemplate)
      Tilt.register('md', Tilt::RDiscountTemplate)
      Tilt.register('mkd', Tilt::RDiscountTemplate)
    end

    test "registered for '.markdown' files unless RDiscount is loaded" do
      unless defined?(RDiscount)
        assert_equal Tilt::MarukuTemplate, Tilt['test.markdown']
      end
    end

    test "registered for '.md' files unless RDiscount is loaded" do
      unless defined?(RDiscount)
        assert_equal Tilt::MarukuTemplate, Tilt['test.md']
      end
    end

    test "registered for '.mkd' files unless RDiscount is loaded" do
      unless defined?(RDiscount)
        assert_equal Tilt::MarukuTemplate, Tilt['test.mkd']
      end
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::MarukuTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1 id='hello_world'>Hello World!</h1>", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::MarukuTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1 id='hello_world'>Hello World!</h1>", template.render }
    end

    test "removes HTML when :filter_html is set" do
      template = Tilt::MarukuTemplate.new(:filter_html => true) { |t|
        "HELLO <blink>WORLD</blink>" }
      assert_equal "<p>HELLO </p>", template.render
    end
  end
rescue LoadError => boom
  warn "Tilt::MarukuTemplate (disabled)\n"
end
