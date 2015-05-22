require_relative 'test_helper'

class PipelineTest < Minitest::Test
  setup do
    @mapping = Tilt.default_mapping.dup
    @pipeline_class = @mapping.register_pipeline('str.erb')
  end

  test "returns a template class" do
    assert_equal Tilt::Pipeline, @pipeline_class.superclass
  end

  test "registers itself for the given extension" do
    assert_equal @pipeline_class, @mapping['test.str.erb']
  end

  test "renders templates starting with final extension to inner extensions" do
    template = @pipeline_class.new { |t| '#<%= \'{a = 1}\' %><%= \'#{a}\' %>' }
    assert_equal "11", template.render
  end

  test "can be rendered more than once" do
    template = @pipeline_class.new { |t| '<%= \'#{1}\' %>' }
    3.times { assert_equal "1", template.render }
  end

  test "passing locals" do
    template = @pipeline_class.new { |t| '<%= \'#{a}\' * a %>' }
    assert_equal "333", template.render(Object.new, :a => 3)
  end

  test "evaluating in an object scope" do
    template = @pipeline_class.new { |t| '<%= \'#{a}\' * a %>' }
    o = Object.new
    def o.a; 3 end
    assert_equal "333", template.render(o)
  end

  test "passing a block for yield" do
    template = @pipeline_class.new { |t| '<%= \'#{yield}\' * yield %>' }
    assert_equal "333", template.render { 3 }
    assert_equal "22", template.render { 2 }
  end
end

class PipelineOptionsTest < Minitest::Test
  setup do
    @mapping = Tilt.default_mapping.dup
  end

  test "supports :templates option for specifying templates to use in order" do
    pipeline = @mapping.register_pipeline('setrrb', :templates=>['erb', 'str'])
    template = pipeline.new { |t| '#<%= \'{a = 1}\' %><%= \'#{a}\' %>' }
    assert_equal "11", template.render
  end

  test "supports :extra_exts option for specifying additional extensions to register" do
    @mapping.register_pipeline('str.erb', :extra_exts=>['setrrb', 'asdfoa'])
    ['str.erb', 'setrrb', 'asdfoa'].each do |ext|
      template = @mapping[ext].new { |t| '#<%= \'{a = 1}\' %><%= \'#{a}\' %>' }
      assert_equal "11", template.render
    end
  end

  test "supports per template class options" do
    pipeline = @mapping.register_pipeline('str.erb', 'erb'=>{:outvar=>'@foo'})
    template = pipeline.new { |t| '#<% @foo << \'{a = 1}\' %><%= \'#{a}\' %>' }
    assert_equal "11", template.render
  end
end
