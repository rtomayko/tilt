require 'test_helper'
require 'tilt'

begin
  require 'tilt/livescript'

  module LiveScriptTests
    setup do
      @code_without_variables = "puts 'Hello, World!'\n"
      @code_with_variables = 'name = "Josh"; puts "Hello, #{name}"'
      @renderer = Tilt::LiveScriptTemplate
    end
    def self.included(mod)
      mod.class_eval do
        test "bare is disabled by default" do
          assert_equal false, @renderer.default_bare
        end

        test "compiles and evaluates the template on #render" do
          template = @renderer.new { |t| @code_without_variables }
          assert_match "puts('Hello, World!');", template.render
        end

        test "can be rendered more than once" do
          template = @renderer.new { |t| @code_without_variables }
          3.times { assert_match "puts('Hello, World!');", template.render }
        end

        test "disabling live-script wrapper" do
          template = @renderer.new { @code_with_variables }
          assert_match "(function() {", template.render
          assert_match "puts(\"Hello, \" + name);\n", template.render

          template = @renderer.new(:bare => true) { @code_with_variables }
          refute_match "(function() {", template.render
          assert_equal "var name;\n\nname = \"Josh\";\n\nputs(\"Hello, \" + name);\n", template.render

        end

        context "wrapper globally enabled" do
          setup do
            @bare = @renderer.default_bare
            @renderer.default_bare = false
          end

          teardown do
            @renderer.default_bare = @bare
          end

          test "no options" do
            template = @renderer.new { |t| @code_with_variables }
            assert_match "puts(\"Hello, \" + name);", template.render
            assert_match "(function() {", template.render
          end

          test "overridden by :bare" do
            template = @renderer.new(:bare => true) { |t| @code_with_variables }
            assert_match "puts(\"Hello, \" + name);", template.render
            refute_match "(function() {", template.render
          end
        end

        context "wrapper globally disabled" do
          setup do
            @bare = @renderer.default_bare
            @renderer.default_bare = true
          end

          teardown do
            @renderer.default_bare = @bare
          end

          test "no options" do
            template = @renderer.new { |t| @code_with_variables }
            assert_match "puts(\"Hello, \" + name);", template.render
            refute_match "(function() {", template.render
          end

          test "overridden by :bare" do
            template = @renderer.new(:bare => false) { |t| @code_with_variables }
            assert_match "puts(\"Hello, \" + name);", template.render
            assert_match "(function() {", template.render
          end
        end
      end
    end
  end

  class LiveScriptTemplateTest < Minitest::Test

    include LiveScriptTests

    test "is registered for '.ls' files" do
      assert_equal @renderer, Tilt['test.ls']
    end
  end
rescue LoadError => boom
  warn "Tilt::LiveScriptTemplate (disabled)"
end
