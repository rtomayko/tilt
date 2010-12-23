require 'contest'
require 'tilt'

class MustacheTemplateTest < Test::Unit::TestCase
	test "registered for '.mustache' files" do
		assert_equal Tilt::MustacheTemplate, Tilt["test.mustache"]
	end
	
	test "loading and evaluating templates on #render" do
    template = Tilt::MustacheTemplate.new { |t| "Hello World!" }
    assert_equal "Hello World!", template.render
  end
	
	test "passing locals" do
		template = Tilt::MustacheTemplate.new { "Hey {{name}}!" }
		assert_equal "Hey Joe!", template.render(nil, :name => 'Joe')
  end
	
	test "evaluating in an object scope" do
    template = Tilt::MustacheTemplate.new { 'Hey {{name}}!' }
    assert_equal "Hey Joe!", template.render({:name => 'Joe'})
  end
	
	test "passing a block for yield" do
    template = Tilt::MustacheTemplate.new { 'Hey {{yield}}!' }
    assert_equal "Hey Joe!", template.render { 'Joe' }
  end

end
