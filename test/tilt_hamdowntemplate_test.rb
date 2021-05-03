require 'test_helper'
require 'tilt'

begin
  require 'tilt/hamdown'

  class KramdownTemplateTest < Minitest::Test
    test "preparing and evaluating templates on #render" do
      template = Tilt::HamdownTemplate.new { |t| ".header\n  # Hello World!" }
      assert_equal '<div class="header"><h1 id="hello-world">Hello World!</h1></div>', template.render.strip
    end

    test "can be rendered more than once" do
      template = Tilt::HamdownTemplate.new { |t| ".header\n  # Hello World!" }
      3.times { assert_equal '<div class="header"><h1 id="hello-world">Hello World!</h1></div>', template.render.strip }
    end
  end
rescue LoadError
  warn "Tilt::HamdownTemplate (disabled)"
end
