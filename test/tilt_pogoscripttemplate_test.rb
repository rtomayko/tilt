require 'test_helper'
require 'tilt'

begin
  require 'tilt/pogo'

  class PogoScriptTemplateTest < Minitest::Test

    test "is registered for '.pogo' files" do
      assert_equal Tilt::PogoScriptTemplate, Tilt['test.pogo']
    end

    test "bare is disabled by default" do
      assert_equal false, Tilt::PogoScriptTemplate.default_bare
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::PogoScriptTemplate.new { |t| "puts 'Hello, World!'\n" }
      assert_match "puts('Hello, World!');", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::PogoScriptTemplate.new { |t| "puts 'Hello, World!'\n" }
      3.times { assert_match "puts('Hello, World!');", template.render }
    end

    test "disabling pogo-script wrapper" do
      str = %|name = "Josh"\nputs "Hello, #(name)"|

      template = Tilt::PogoScriptTemplate.new { str }
      assert_match "(function(){", template.render
      assert_match "puts(('Hello, '+name));", template.render

      template = Tilt::PogoScriptTemplate.new(:bare => true) { str }
      refute_match "(function(){", template.render
      assert_equal "var name;name='Josh';puts(('Hello, '+name));", template.render
    end

    context "wrapper globally enabled" do
      setup do
        @bare = Tilt::PogoScriptTemplate.default_bare
        Tilt::PogoScriptTemplate.default_bare = false
      end

      teardown do
        Tilt::PogoScriptTemplate.default_bare = @bare
      end

      test "no options" do
        template = Tilt::PogoScriptTemplate.new { |t| %|name = "Josh"\nputs "Hello, #(name)"| }
        assert_match "puts(('Hello, '+name));", template.render
        assert_match "(function(){", template.render
      end

      test "overridden by :bare" do
        template = Tilt::PogoScriptTemplate.new(:bare => true) { |t| %|name = "Josh"\nputs "Hello, #(name)"| }
        assert_match "puts(('Hello, '+name));", template.render
        refute_match "(function(){", template.render
      end
    end

    context "wrapper globally disabled" do
      setup do
        @bare = Tilt::PogoScriptTemplate.default_bare
        Tilt::PogoScriptTemplate.default_bare = true
      end

      teardown do
        Tilt::PogoScriptTemplate.default_bare = @bare
      end

      test "no options" do
        template = Tilt::PogoScriptTemplate.new { |t| %|name = "Josh"\nputs "Hello, #(name)"| }
        assert_match "puts(('Hello, '+name));", template.render
        refute_match "(function(){", template.render
      end

      test "overridden by :bare" do
        template = Tilt::PogoScriptTemplate.new(:bare => false) { |t| %|name = "Josh"\nputs "Hello, #(name)"| }
        assert_match "puts(('Hello, '+name));", template.render
        assert_match "(function(){", template.render
      end
    end
  end

rescue LoadError => boom
  warn "Tilt::PogoScriptTemplate (disabled)"
end
