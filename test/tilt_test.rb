require_relative 'test_helper'

describe 'tilt' do
  _MockTemplate = Class.new do
    attr_reader :args, :block
    def initialize(*args, &block)
      @args = args
      @block = block
    end
  end

  it "registering template implementation classes by file extension" do
    Tilt.register(_MockTemplate, 'mock')
  end

  it "an extension is registered if explicit handle is found" do
    Tilt.register(_MockTemplate, 'mock')
    assert Tilt.registered?('mock')
  end

  it "registering template classes by symbol file extension" do
    Tilt.register(_MockTemplate, :mock)
  end

  it "looking up template classes by exact file extension" do
    Tilt.register(_MockTemplate, 'mock')
    impl = Tilt['mock']
    assert_equal _MockTemplate, impl
  end

  it "looking up template classes by implicit file extension" do
    Tilt.register(_MockTemplate, 'mock')
    impl = Tilt['.mock']
    assert_equal _MockTemplate, impl
  end

  it "looking up template classes with multiple file extensions" do
    Tilt.register(_MockTemplate, 'mock')
    impl = Tilt['index.html.mock']
    assert_equal _MockTemplate, impl
  end

  it "looking up template classes by file name" do
    Tilt.register(_MockTemplate, 'mock')
    impl = Tilt['templates/test.mock']
    assert_equal _MockTemplate, impl
  end

  it "looking up non-existant template class" do
    assert_nil Tilt['none']
  end

  it "creating new template instance with a filename" do
    Tilt.register(_MockTemplate, 'mock')
    template = Tilt.new('foo.mock', 1, :key => 'val') { 'Hello World!' }
    assert_equal ['foo.mock', 1, {:key => 'val'}], template.args
    assert_equal 'Hello World!', template.block.call
  end
end
