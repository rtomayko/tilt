require 'test_helper'
require 'tilt'

begin
  require 'tilt/livescript'

  class LiveScriptTemplateTest < Minitest::Test

    test "is registered for '.ls' files" do
      assert_equal Tilt::LiveScriptTemplate, Tilt['test.ls']
    end

    test "bare is disabled by default" do
      assert_equal false, Tilt::LiveScriptTemplate.default_bare
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::LiveScriptTemplate.new { |t| "puts 'Hello, World!'\n" }
      assert_match "puts('Hello, World!');", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::LiveScriptTemplate.new { |t| "puts 'Hello, World!'\n" }
      3.times { assert_match "puts('Hello, World!');", template.render }
    end

    test "disabling coffee-script wrapper" do
      str = 'name = "Josh"; puts "Hello #{name}"'

      template = Tilt::LiveScriptTemplate.new { str }
      assert_match "(function(){", template.render
      assert_match "puts(\"Hello \" + name);", template.render

      template = Tilt::LiveScriptTemplate.new(:bare => true) { str }
      refute_match "(function(){", template.render
      assert_equal "var name;\nname = \"Josh\";\nputs(\"Hello \" + name);", template.render
    end

    context "wrapper globally enabled" do
      setup do
        @bare = Tilt::LiveScriptTemplate.default_bare
        Tilt::LiveScriptTemplate.default_bare = false
      end

      teardown do
        Tilt::LiveScriptTemplate.default_bare = @bare
      end

      test "no options" do
        template = Tilt::LiveScriptTemplate.new { |t| 'name = "Josh"; puts "Hello, #{name}"' }
        assert_match "puts(\"Hello, \" + name);", template.render
        assert_match "(function(){", template.render
      end

      test "overridden by :bare" do
        template = Tilt::LiveScriptTemplate.new(:bare => true) { |t| 'name = "Josh"; puts "Hello, #{name}"' }
        assert_match "puts(\"Hello, \" + name);", template.render
        refute_match "(function(){", template.render
      end

      test "overridden by :no_wrap" do
        template = Tilt::LiveScriptTemplate.new(:no_wrap => true) { |t| 'name = "Josh"; puts "Hello, #{name}"' }
        assert_match "puts(\"Hello, \" + name);", template.render
        refute_match "(function() {", template.render
      end
    end

    context "wrapper globally disabled" do
      setup do
        @bare = Tilt::LiveScriptTemplate.default_bare
        Tilt::LiveScriptTemplate.default_bare = true
      end

      teardown do
        Tilt::LiveScriptTemplate.default_bare = @bare
      end

      test "no options" do
        template = Tilt::LiveScriptTemplate.new { |t| 'name = "Josh"; puts "Hello, #{name}"' }
        assert_match "puts(\"Hello, \" + name);", template.render
        refute_match "(function() {", template.render
      end

      test "overridden by :bare" do
        template = Tilt::LiveScriptTemplate.new(:bare => false) { |t| 'name = "Josh"; puts "Hello, #{name}"' }
        assert_match "puts(\"Hello, \" + name);", template.render
        assert_match "(function(){", template.render
      end
    end
  end

rescue LoadError => boom
  warn "Tilt::LiveScriptTemplate (disabled)"
end

