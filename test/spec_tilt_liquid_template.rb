require 'bacon'
require 'tilt'

begin
  require 'liquid'

  describe Tilt::LiquidTemplate do
    it "is registered for '.liquid' files" do
      Tilt['test.liquid'].should.equal Tilt::LiquidTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::LiquidTemplate.new { |t| "Hello World!" }
      template.render.should.equal "Hello World!"
    end

    it "supports locals" do
      template = Tilt::LiquidTemplate.new { "Hey {{ name }}!" }
      template.render(nil, :name => 'Joe').should.equal "Hey Joe!"
    end

    # Object's passed as "scope" to LiquidTemplate may respond to
    # #to_h with a Hash. The Hash's contents are merged underneath
    # Tilt locals.
    class ExampleLiquidScope
      def to_h
        { :beer => 'wet', :whisky => 'wetter' }
      end
    end

    it "merges scope Hash in under locals when scope responds to #to_h" do
      template =
        Tilt::LiquidTemplate.new {
          'Beer is {{ beer }} but Whisky is {{ whisky }}.'
        }
      scope = ExampleLiquidScope.new
      template.render(scope).should.equal "Beer is wet but Whisky is wetter."
    end

    it "gives locals presendence over scope defined variables" do
      template =
        Tilt::LiquidTemplate.new {
          'Beer is {{ beer }} but Whisky is {{ whisky }}.'
        }
      scope = ExampleLiquidScope.new
      template.render(scope, :beer => 'great', :whisky => 'greater').
        should.equal "Beer is great but Whisky is greater."
    end

    # Object's passed as "scope" to LiquidTemplate that do not
    # respond to #to_h are silently ignored.
    class ExampleIgnoredLiquidScope
    end

    it "does not freak out when scope does not respond to #to_h" do
      template = Tilt::LiquidTemplate.new { 'Whisky' }
      scope = ExampleIgnoredLiquidScope.new
      template.render(scope).should.equal "Whisky"
    end
  end

rescue LoadError => boom
  warn "Tilt::LiquidTemplate (disabled)\n"
end
