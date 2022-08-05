require_relative 'test_helper'

describe 'tilt/mapping' do
  _Stub = Class.new
  _Stub2 = Class.new

  before do
    @mapping = Tilt::Mapping.new
  end

  it "registered?" do
    @mapping.register(_Stub, 'foo', 'bar')
    assert @mapping.registered?('foo')
    assert @mapping.registered?('bar')
    refute @mapping.registered?('baz')
  end

  it "lookups on registered" do
    @mapping.register(_Stub, 'foo', 'bar')
    assert_equal _Stub, @mapping['foo']
    assert_equal _Stub, @mapping['bar']
    assert_equal _Stub, @mapping['hello.foo']
    assert_nil @mapping['foo.baz']
  end

  it "can be dup'd" do
    @mapping.register(_Stub, 'foo')
    other = @mapping.dup
    assert other.registered?('foo')

    # @mapping doesn't leak to other
    @mapping.register(_Stub, 'bar')
    refute other.registered?('bar')

    # other doesn't leak to @mapping
    other.register(_Stub, 'baz')
    refute @mapping.registered?('baz')
  end

  it "#extensions_for" do
    @mapping.register(_Stub, 'foo', 'bar')
    assert_equal ['foo', 'bar'].sort, @mapping.extensions_for(_Stub).sort
  end

  it "supports old-style #register" do
    @mapping.register('foo', _Stub)
    assert_equal _Stub, @mapping['foo']
  end

  describe "lazy with one template class" do
    before do
      @mapping.register_lazy('MyTemplate', 'my_template', 'mt')
      @loaded_before = $LOADED_FEATURES.dup
    end

    after do
      Object.send :remove_const, :MyTemplate if defined? ::MyTemplate
      $LOADED_FEATURES.replace(@loaded_before)
    end

    it "registered?" do
      assert @mapping.registered?('mt')
    end

    it "#extensions_for" do
      assert_equal ['mt'], @mapping.extensions_for('MyTemplate')
    end

    it "basic lookup" do
      req = proc do |file|
        assert_equal 'my_template', file
        class ::MyTemplate; end
        true
      end

      @mapping.stub :require, req do
        klass = @mapping['hello.mt']
        assert_equal ::MyTemplate, klass
      end
    end

    it "doesn't require when template class is present" do
      class ::MyTemplate; end

      req = proc do |file|
        flunk "#require shouldn't be called"
      end

      @mapping.stub :require, req do
        klass = @mapping['hello.mt']
        assert_equal ::MyTemplate, klass
      end
    end

    it "doesn't require when the template class is autoloaded, and then defined" do
      $LOAD_PATH << __dir__
      begin
        Object.autoload :MyTemplate, 'mytemplate'
        did_load = require 'mytemplate'
      ensure
        $LOAD_PATH.delete(__dir__)
      end
      assert did_load, "mytemplate wasn't freshly required"

      req = proc do |file|
        flunk "#require shouldn't be called"
      end

      @mapping.stub :require, req do
        klass = @mapping['hello.mt']
        assert_equal ::MyTemplate, klass
      end
    end

    it "raises NameError when the class name is defined" do
      req = proc do |file|
        # do nothing
      end

      @mapping.stub :require, req do
        assert_raises(NameError) do
          @mapping['hello.mt']
        end
      end
    end
  end

  describe "lazy with two template classes" do
    before do
      @mapping.register_lazy('MyTemplate1', 'my_template1', 'mt')
      @mapping.register_lazy('MyTemplate2', 'my_template2', 'mt')
    end

    after do
      Object.send :remove_const, :MyTemplate1 if defined? ::MyTemplate1
      Object.send :remove_const, :MyTemplate2 if defined? ::MyTemplate2
    end

    it "registered?" do
      assert @mapping.registered?('mt')
    end

    it "only attempt to load the last template" do
      req = proc do |file|
        assert_equal 'my_template2', file
        class ::MyTemplate2; end
        true
      end

      @mapping.stub :require, req do
        klass = @mapping['hello.mt']
        assert_equal ::MyTemplate2, klass
      end
    end

    it "uses the first template if it's present" do
      class ::MyTemplate1; end

      req = proc do |file|
        flunk
      end

      @mapping.stub :require, req do
        klass = @mapping['hello.mt']
        assert_equal ::MyTemplate1, klass
      end
    end

    it "falls back when LoadError is thrown" do
      req = proc do |file|
        raise LoadError unless file == 'my_template1'
        class ::MyTemplate1; end
        true
      end

      @mapping.stub :require, req do
        klass = @mapping['hello.mt']
        assert_equal ::MyTemplate1, klass
      end
    end

    it "raises the first LoadError when everything fails" do
      req = proc do |file|
        raise LoadError, file
      end

      @mapping.stub :require, req do
        err = assert_raises(LoadError) do
          @mapping['hello.mt']
        end

        assert_equal 'my_template2', err.message
      end
    end

    it "handles autoloaded constants" do
      Object.autoload :MyTemplate2, 'my_template2'
      class ::MyTemplate1; end

      assert_equal MyTemplate1, @mapping['hello.mt']
    end
  end

  it "raises NameError on invalid class name" do
    @mapping.register_lazy '#foo', 'my_template', 'mt'

    req = proc do |file|
      # do nothing
    end

    @mapping.stub :require, req do
      assert_raises(NameError) do
        @mapping['hello.mt']
      end
    end
  end

  describe "#templates_for" do
    before do
      @mapping.register _Stub, 'a'
      @mapping.register _Stub2, 'b'
    end

    it "handles multiple engines" do
      assert_equal [_Stub2, _Stub], @mapping.templates_for('hello/world.a.b')
    end
  end
end
