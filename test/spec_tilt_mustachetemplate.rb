require 'bacon'
require 'tilt'

begin
  require 'mustache'
  raise LoadError, "mustache version must be > 0.2.2" if !Mustache.respond_to?(:compiled?)

  describe "Tilt::MustacheTemplate" do
    it "is registered for '.mustache' files" do
      Tilt['test.mustache'].should.equal Tilt::MustacheTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::MustacheTemplate.new { |t| "Hello World!" }
      template.render.should.equal "Hello World!"
    end

    it "supports locals" do
      template = Tilt::MustacheTemplate.new { "<p>Hey {{name}}!</p>" }
      template.render(nil, :name => 'Joe').should.equal "<p>Hey Joe!</p>"
    end

    it "evaluates template_source with yield support" do
      template = Tilt::MustacheTemplate.new { "<p>Hey {{yield}}!</p>" }
      template.render { 'Joe' }.should.equal "<p>Hey Joe!</p>"
    end

    module Views
      class Foo < Mustache
        attr_reader :foo
      end
    end

    it "locates views defined at the top-level by default" do
      template = Tilt::MustacheTemplate.new('foo.mustache') { "<p>Hey {{foo}}!</p>" }
      template.compile
      template.engine.should.equal Views::Foo
    end

    module Bar
      module Views
        class Bizzle < Mustache
        end
      end
    end

    it "locates views defined in a custom namespace" do
      template = Tilt::MustacheTemplate.new('bizzle.mustache', :namespace => Bar) { "<p>Hello World!</p>" }
      template.compile
      template.engine.should.equal Bar::Views::Bizzle
      template.render.should.equal "<p>Hello World!</p>"
    end

    it "copies instance variables from scope object" do
      template = Tilt::MustacheTemplate.new('foo.mustache') { "<p>Hey {{foo}}!</p>" }
      scope = Object.new
      scope.instance_variable_set(:@foo, 'Jane!')
      template.render(scope).should.equal "<p>Hey Jane!!</p>"
    end
  end

rescue LoadError => boom
  warn "Tilt::MustacheTemplate (disabled)\n"
end
