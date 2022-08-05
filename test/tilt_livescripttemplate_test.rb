require_relative 'test_helper'

begin
  require 'tilt/livescript'

  describe 'tilt/livescript' do
    before do
      @code_without_variables = "puts 'Hello, World!'\n"
      @renderer = Tilt::LiveScriptTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = @renderer.new { |t| @code_without_variables }
      assert_match "puts('Hello, World!');", template.render
    end

    it "can be rendered more than once" do
      template = @renderer.new { |t| @code_without_variables }
      3.times { assert_match "puts('Hello, World!');", template.render }
    end

    it "supports bare-option" do
      template = @renderer.new(:bare => false) { |t| @code_without_variables }
      assert_match "function", template.render

      template = @renderer.new(:bare => true) { |t| @code_without_variables }
      refute_match "function", template.render
    end

    it "is registered for '.ls' files" do
      assert_equal @renderer, Tilt['test.ls']
    end
  end
rescue LoadError
  warn "Tilt::LiveScriptTemplate (disabled)"
end
