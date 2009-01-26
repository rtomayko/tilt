require 'bacon'
require 'tilt'

describe "Tilt" do
  class MockTemplate
    attr_reader :args, :block
    def initialize(*args, &block)
      @args = args
      @block = block
    end
  end

  it "registers template implementation classes by file extension" do
    lambda { Tilt.register('mock', MockTemplate) }.should.not.raise
  end

  it "looks up template implementation classes by file extension" do
    impl = Tilt['mock']
    impl.should.equal MockTemplate

    impl = Tilt['.mock']
    impl.should.equal MockTemplate
  end

  it "looks up template implementation classes with multiple file extensions" do
    impl = Tilt['index.html.mock']
    impl.should.equal MockTemplate
  end

  it "looks up template implementation classes by file name" do
    impl = Tilt['templates/test.mock']
    impl.should.equal MockTemplate
  end

  it "gives nil when no template implementation classes exist for a filename" do
    Tilt['none'].should.be.nil
  end

  it "creates a new template instance given a filename" do
    template = Tilt.new('foo.mock', 1, :key => 'val') { 'Hello World!' }
    template.args.should.equal ['foo.mock', 1, {:key => 'val'}]
    template.block.call.should.equal 'Hello World!'
  end
end
