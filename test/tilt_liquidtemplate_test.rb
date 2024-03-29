require_relative 'test_helper'

begin
  require 'tilt/liquid'

  describe 'tilt/liquid' do
    it "registered for '.liquid' files" do
      assert_equal Tilt::LiquidTemplate, Tilt['test.liquid']
    end

    it "preparing and evaluating templates on #render" do
      template = Tilt::LiquidTemplate.new { |t| "Hello World!" }
      assert_equal "Hello World!", template.render
    end

    it "can be rendered more than once" do
      template = Tilt::LiquidTemplate.new { |t| "Hello World!" }
      3.times { assert_equal "Hello World!", template.render }
    end

    it "passing locals" do
      template = Tilt::LiquidTemplate.new { "Hey {{ name }}!" }
      assert_equal "Hey Joe!", template.render(nil, :name => 'Joe')
    end

    it "options can be set" do
      err = assert_raises(Liquid::SyntaxError) do
        options = { line_numbers: false, error_mode: :strict }
        Tilt::LiquidTemplate.new(options) { "{{%%%}}" }.render
      end
      assert_equal 'Liquid syntax error: Unexpected character % in "{{%%%}}"',
        err.message
    end

    # Object's passed as "scope" to LiquidTemplate may respond to
    # #to_h with a Hash. The Hash's contents are merged underneath
    # Tilt locals.
    class ExampleLiquidScope
      def to_h
        { :beer => 'wet', :whisky => 'wetter' }
      end
    end

    it "combining scope and locals when scope responds to #to_h" do
      template =
        Tilt::LiquidTemplate.new {
          'Beer is {{ beer }} but Whisky is {{ whisky }}.'
        }
      scope = ExampleLiquidScope.new
      assert_equal "Beer is wet but Whisky is wetter.", template.render(scope)
    end

    it "precedence when locals and scope define same variables" do
      template =
        Tilt::LiquidTemplate.new {
          'Beer is {{ beer }} but Whisky is {{ whisky }}.'
        }
      scope = ExampleLiquidScope.new
      assert_equal "Beer is great but Whisky is greater.",
        template.render(scope, :beer => 'great', :whisky => 'greater')
    end

    # Object's passed as "scope" to LiquidTemplate that do not
    # respond to #to_h are silently ignored.
    class ExampleIgnoredLiquidScope
    end

    it "handling scopes that do not respond to #to_h" do
      template = Tilt::LiquidTemplate.new { 'Whisky' }
      scope = ExampleIgnoredLiquidScope.new
      assert_equal "Whisky", template.render(scope)
    end

    it "passing a block for yield" do
      template =
        Tilt::LiquidTemplate.new {
          'Beer is {{ yield }} but Whisky is {{ content }}ter.'
        }
      assert_equal "Beer is wet but Whisky is wetter.",
        template.render({}) { 'wet' }
    end
  end

rescue LoadError
  warn "Tilt::LiquidTemplate (disabled)"
end
