require 'contest'
require 'tilt'

begin
  require 'coffee-script'

  class CoffeeTemplateTest < Test::Unit::TestCase
    test "is registered for '.coffee' files" do
      assert_equal Tilt::CoffeeTemplate, Tilt['test.coffee']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::CoffeeTemplate.new { |t| "greeting: \"Hello CoffeeScript\"" }
      assert_equal "(function(){\n  var greeting;\n  greeting = \"Hello CoffeeScript\";\n})();", template.render
    end
  end

rescue LoadError => boom
  warn "Tilt::CoffeeTemplate (disabled)\n"
end
