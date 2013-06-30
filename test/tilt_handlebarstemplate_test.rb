require 'test_helper'
require 'tilt'

def make_template(text)
  Tilt::HandlebarsTemplate.new { |t| text }
end


begin
  require 'tilt/handlebars'

  class HandlebarsTemplateTest < Minitest::Test
    test "registered for '.handlebars' files" do
      assert_equal Tilt::HandlebarsTemplate, Tilt['test.handlebars']
    end

    test "registered for '.hbs' files" do
      assert_equal Tilt::HandlebarsTemplate, Tilt['test.hbs']
    end

    test "preparing and evaluating templates on #render" do
      template = make_template "Hello World!" 
      assert_equal "Hello World!", template.render
    end

    test "can be rendered more than once" do
      template = make_template "Hello World!" 
      3.times { assert_equal "Hello World!", template.render }
    end

    test "passing locals" do
      template = make_template "Hey {{ name }}!" 
      assert_equal "Hey Joe!", template.render(nil, :name => 'Joe')
    end

    test "nested expressions" do
      template = make_template "Hey {{ person.name }}!" 
      assert_equal "Hey Joe!", template.render(nil, :person => { :name => 'Joe' })
    end

    test "array expressions" do
      template = make_template "Don't forget the {{ shopping_list.[1] }}!"
      shopping_list = %w[milk eggs flour sugar]
      assert_equal "Don't forget the eggs!", template.render(nil, :shopping_list => shopping_list)
    end

    test "each-loop expressions" do
      template = make_template 'Items to buy:{{#each shopping_list}} {{ this }}{{/each}}' 
      shopping_list = %w[milk eggs flour sugar]
      assert_equal "Items to buy: milk eggs flour sugar", template.render(nil, :shopping_list => shopping_list)
    end

    test "each-loop with empty list" do
      template = make_template 'Items to buy:{{#each shopping_list}} {{ this }}{{else}} All done!{{/each}}' 
      shopping_list = []
      assert_equal "Items to buy: All done!", template.render(nil, :shopping_list => shopping_list)
    end

    test "if-else expressions" do
      template = make_template '{{#if morning}}Good morning{{else}}Hello{{/if}}, {{ name }}'
      assert_equal "Good morning, Joe", template.render(nil, :name => 'Joe', :morning => true)
      assert_equal "Hello, Joe", template.render(nil, :name => 'Joe', :morning => false)
      assert_equal "Hello, Joe", template.render(nil, :name => 'Joe')
    end

    test "unless expressions" do
      template = make_template 'Hello, {{ name }}.{{#unless weekend}} Time to go to work.{{/unless}}'
      assert_equal "Hello, Joe. Time to go to work.", template.render(nil, :name => 'Joe')
      assert_equal "Hello, Joe. Time to go to work.", template.render(nil, :name => 'Joe', :weekend => false)
      assert_equal "Hello, Joe.", template.render(nil, :name => 'Joe', :weekend => true)
    end

    test "escape html" do
      template = make_template "Hey {{ name }}!" 
      assert_equal "Hey &lt;b&gt;Joe&lt;/b&gt;!", template.render(nil, :name => '<b>Joe</b>' )
    end

    test "do not escape html in triple-stash" do
      template = make_template "Hey {{{ name }}}!" 
      assert_equal "Hey <b>Joe</b>!", template.render(nil, :name => '<b>Joe</b>' )
    end

    test "helpers support" do
      template = make_template '{{#upper}}Hey {{name}}{{/upper}}!'
      template.register_helper(:upper) do |this, block|
        block.fn(this).upcase
      end
      assert_equal "HEY JOE!", template.render(nil, :name => 'Joe')
    end

    test "partials support" do
      template = make_template "{{> greeting}}. Nice to meet you."
      template.register_partial :greeting, "Hey, {{name}}"
      assert_equal "Hey, Joe. Nice to meet you.", template.render(nil, :name => "Joe")
    end

    test "partial missing" do
      template = make_template "{{> where}} I've been looking for you."
      template.partial_missing do |partial_name|
        "Where have you been, {{name}}?" if partial_name == 'where'
      end
      assert_equal "Where have you been, Joe? I've been looking for you.", template.render(nil, :name => "Joe")
    end

    class Person
      attr_reader :first_name, :last_name

      def initialize(first_name, last_name)
        @first_name = first_name
        @last_name = last_name
      end
    end

    test "using object in locals" do
      template = make_template "Hello, {{ person.first_name }} {{ person.last_name }}"
      joe = Person.new "Joe", "Blow"
      assert_equal "Hello, Joe Blow", template.render(nil, :person => joe)
    end

    test "using object in scope" do
      template = make_template "Hello, {{ first_name }} {{ last_name }}"
      joe = Person.new "Joe", "Blow"
      assert_equal "Hello, Joe Blow", template.render(joe)
    end

    test "object in scope merges with locals" do
      template = make_template "{{ greeting }}, {{ first_name }} {{ last_name }}"
      joe = Person.new "Joe", "Blow"
      assert_equal "Salut, Joe Blow", template.render(joe, :greeting => "Salut")
    end

    test "comments do not render" do
      template = make_template "Hello world{{! what a wonderful world }}"
      assert_equal "Hello world", template.render
    end

    test "comments do not render, alternative syntax" do
      template = make_template "Hello world{{!-- what a wonderful world --}}"
      assert_equal "Hello world", template.render
    end

    test "using with block" do
      template = make_template '{{#with person}}Hello, {{ first_name }} {{ last_name }}{{/with}}'
      joe = Person.new "Joe", "Blow"
      assert_equal "Hello, Joe Blow", template.render(nil, :person => joe)
    end


    # Object's passed as "scope" to HandlebarsTemplate may respond to
    # #to_h with a Hash. The Hash's contents are merged underneath
    # Tilt locals.
    class ExampleHandlebarsScope
      def initialize
        @hidden = "you can't see me"
      end

      def to_h
        { :beer => 'wet', :whisky => 'wetter' }
      end
    end

    test "instance variables hidden if to_h defined" do
      template =
        make_template 'Beer is {{ beer }} but Whisky is {{ whisky }} and hidden is {{ hidden }}.'
      scope = ExampleHandlebarsScope.new
      assert_equal "Beer is wet but Whisky is wetter and hidden is .", template.render(scope)
    end


    test "combining scope and locals when scope responds to #to_h" do
      template =
        make_template 'Beer is {{ beer }} but Whisky is {{ whisky }}.'
      scope = ExampleHandlebarsScope.new
      assert_equal "Beer is wet but Whisky is wetter.", template.render(scope)
    end

    test "precedence when locals and scope define same variables" do
      template =
        make_template 'Beer is {{ beer }} but Whisky is {{ whisky }}.'

      scope = ExampleHandlebarsScope.new
      assert_equal "Beer is great but Whisky is greater.",
        template.render(scope, :beer => 'great', :whisky => 'greater')
    end

    test "passing a block for yield" do
      template =
        make_template 'Beer is {{ yield }} but Whisky is {{ content }}ter.'
      assert_equal "Beer is wet but Whisky is wetter.",
        template.render({}) { 'wet' }
    end
  end

rescue LoadError => boom
  warn "Tilt::HandlebarsTemplate (disabled)"
end
