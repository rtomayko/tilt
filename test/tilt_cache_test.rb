require_relative 'test_helper'

describe 'Tilt::Cache' do
  before { @cache = Tilt::Cache.new }

  it "caching with single simple argument to #fetch" do
    template = nil
    result = @cache.fetch('hello') { template = Tilt::StringTemplate.new {''} }
    assert_same template, result
    result = @cache.fetch('hello') { fail 'should be cached' }
    assert_same template, result
  end

  it "caching with multiple complex arguments to #fetch" do
    template = nil
    result = @cache.fetch('hello', {:foo => 'bar', :baz => 'bizzle'}) { template = Tilt::StringTemplate.new {''} }
    assert_same template, result
    result = @cache.fetch('hello', {:foo => 'bar', :baz => 'bizzle'}) { fail 'should be cached' }
    assert_same template, result
  end

  it "caching nil" do
    called = false
    result = @cache.fetch("blah") {called = true; nil}
    assert_equal true, called
    assert_nil result
    called = false
    result = @cache.fetch("blah") {called = true; :blah}
    assert_equal false, called
    assert_nil result
  end

  it "clearing the cache with #clear" do
    template, other = nil
    result = @cache.fetch('hello') { template = Tilt::StringTemplate.new {''} }
    assert_same template, result

    @cache.clear
    result = @cache.fetch('hello') { other = Tilt::StringTemplate.new {''} }
    assert_same other, result
  end
end
