require 'test_helper'
require 'tilt'
require 'tilt/mapping'

module Tilt

  class MappingTest < MiniTest::Unit::TestCase
    class Stub
    end

    setup do
      @mapping = Mapping.new
      @mapping.register(Stub, 'foo', 'bar')
    end

    test "registered?" do
      assert @mapping.registered?('foo')
      assert @mapping.registered?('bar')
      refute @mapping.registered?('baz')
    end

    test "lookup" do
      assert_equal Stub, @mapping['foo']
      assert_equal Stub, @mapping['bar']
      assert_equal Stub, @mapping['hello.foo']
      assert_nil @mapping['foo.baz']
    end
  end
end

