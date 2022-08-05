require_relative 'test_helper'

begin
  require 'tilt/coffee'

  _CoffeeScriptTests = proc do
    it "bare is disabled by default" do
      assert_equal false, @renderer.default_bare
    end

    it "compiles and evaluates the template on #render" do
      template = @renderer.new { |t| @code_without_variables }
      assert_match "puts('Hello, World!');", template.render
    end

    it "can be rendered more than once" do
      template = @renderer.new { |t| @code_without_variables }
      3.times { assert_match "puts('Hello, World!');", template.render }
    end

    it "disabling coffee-script wrapper" do
      template = @renderer.new { @code_with_variables }
      assert_match "(function() {", template.render
      assert_match "puts(\"Hello, \" + name);\n", template.render

      template = @renderer.new(:bare => true) { @code_with_variables }
      refute_match "(function() {", template.render
      assert_equal "var name;\n\nname = \"Josh\";\n\nputs(\"Hello, \" + name);\n", template.render

      template = @renderer.new(:no_wrap => true) { @code_with_variables}
      refute_match "(function() {", template.render
      assert_equal "var name;\n\nname = \"Josh\";\n\nputs(\"Hello, \" + name);\n", template.render
    end

    describe "wrapper globally enabled" do
      before do
        @bare = @renderer.default_bare
        @renderer.default_bare = false
      end

      after do
        @renderer.default_bare = @bare
      end

      it "no options" do
        template = @renderer.new { |t| @code_with_variables }
        assert_match "puts(\"Hello, \" + name);", template.render
        assert_match "(function() {", template.render
      end

      it "overridden by :bare" do
        template = @renderer.new(:bare => true) { |t| @code_with_variables }
        assert_match "puts(\"Hello, \" + name);", template.render
        refute_match "(function() {", template.render
      end

      it "overridden by :no_wrap" do
        template = @renderer.new(:no_wrap => true) { |t| @code_with_variables }
        assert_match "puts(\"Hello, \" + name);", template.render
        refute_match "(function() {", template.render
      end
    end

    describe "wrapper globally disabled" do
      before do
        @bare = @renderer.default_bare
        @renderer.default_bare = true
      end

      after do
        @renderer.default_bare = @bare
      end

      it "no options" do
        template = @renderer.new { |t| @code_with_variables }
        assert_match "puts(\"Hello, \" + name);", template.render
        refute_match "(function() {", template.render
      end

      it "overridden by :bare" do
        template = @renderer.new(:bare => false) { |t| @code_with_variables }
        assert_match "puts(\"Hello, \" + name);", template.render
        assert_match "(function() {", template.render
      end

      it "overridden by :no_wrap" do
        template = @renderer.new(:no_wrap => false) { |t| @code_with_variables }
        assert_match "puts(\"Hello, \" + name);", template.render
        assert_match "(function() {", template.render
      end
    end
  end

  describe 'tilt coffeescript' do
    before do
      @code_without_variables = "puts 'Hello, World!'\n"
      @code_with_variables = 'name = "Josh"; puts "Hello, #{name}"'
      @renderer = Tilt::CoffeeScriptTemplate
    end

    class_eval(&_CoffeeScriptTests)

    it "is registered for '.coffee' files" do
      assert_equal @renderer, Tilt['test.coffee']
    end
  end

  describe 'tilt literate coffeescript' do
    before do
      @code_without_variables = <<EOLIT
This is some comment.

    puts 'Hello, World!'

This is a comment too.
EOLIT
      @code_with_variables = <<EOLIT
This is some comment.

    name = "Josh"; puts "Hello, \#{name}"

This is a comment too.
EOLIT
      @renderer = Tilt::CoffeeScriptLiterateTemplate
    end

    class_eval(&_CoffeeScriptTests)

    it "is registered for '.litcoffee' files" do
      assert_equal @renderer, Tilt['test.litcoffee']
    end
  end

rescue LoadError
  warn "Tilt::CoffeeScriptTemplate (disabled)"
end
