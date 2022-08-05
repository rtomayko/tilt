require_relative 'test_helper'

begin
  require 'tilt/radius'

  # Disable radius tests for old Radius versions since it's still buggy.
  # Remove when fixed upstream.
  raise LoadError if Radius.version < "0.7"

  describe 'tilt/radius' do
    it "registered for '.radius' files" do
      assert_equal Tilt::RadiusTemplate, Tilt['test.radius']
    end

    it "preparing and evaluating templates on #render" do
      template = Tilt::RadiusTemplate.new { |t| "Hello World!" }
      assert_equal "Hello World!", template.render
    end

    it "can be rendered more than once" do
      template = Tilt::RadiusTemplate.new { |t| "Hello World!" }
      3.times { assert_equal "Hello World!", template.render }
    end

    it "passing locals" do
      template = Tilt::RadiusTemplate.new { "Hey <r:name />!" }
      assert_equal "Hey Joe!", template.render(nil, :name => 'Joe')
    end

    _ExampleRadiusScope = Class.new do
      def beer; 'wet'; end
      def whisky; 'wetter'; end
    end

    it "combining scope and locals when scope responds" do
      template = Tilt::RadiusTemplate.new {
        'Beer is <r:beer /> but Whisky is <r:whisky />.'
      }
      scope = _ExampleRadiusScope.new
      assert_equal "Beer is wet but Whisky is wetter.", template.render(scope)
    end

    it "precedence when locals and scope define same variables" do
      template = Tilt::RadiusTemplate.new {
        'Beer is <r:beer /> but Whisky is <r:whisky />.'
      }
      scope = _ExampleRadiusScope.new
      assert_equal "Beer is great but Whisky is greater.",
        template.render(scope, :beer => 'great', :whisky => 'greater')
    end

    #it "handles local scope" do
    #  beer   = 'wet'
    #  whisky = 'wetter'
    #
    #  template = Tilt::RadiusTemplate.new {
    #    'Beer is <r:beer /> but Whisky is <r:whisky />.'
    #  }
    #  assert_equal "Beer is wet but Whisky is wetter.", template.render(self)
    #end

    it "passing a block for yield" do
      template = Tilt::RadiusTemplate.new {
        'Beer is <r:yield /> but Whisky is <r:yield />ter.'
      }
      assert_equal "Beer is wet but Whisky is wetter.",
        template.render({}) { 'wet' }
    end
  end

rescue LoadError
  warn "Tilt::RadiusTemplate (disabled)"
end

