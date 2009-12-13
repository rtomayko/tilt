require 'bacon'
require 'tilt'

describe Tilt::Cache do
  before do
    @cache = Tilt::Cache.new
  end

  it "caches with single simple argument to #fetch" do
    template = nil
    result = @cache.fetch('hello') { template = Tilt::StringTemplate.new {''} }
    result.object_id.should.equal template.object_id
    result = @cache.fetch('hello') { fail 'should be cached' }
    result.object_id.should.equal template.object_id
  end

  it "caches with multiple complex arguments to #fetch" do
    template = nil
    args = ['hello', {:foo => 'bar', :baz => 'bizzle'}]
    result = @cache.fetch(*args) { template = Tilt::StringTemplate.new {''} }
    result.object_id.should.equal template.object_id
    result = @cache.fetch(*args) { fail 'should be cached' }
    result.object_id.should.equal template.object_id
  end

  it "clears the cache on #clear" do
    template, other = nil
    result = @cache.fetch('hello') { template = Tilt::StringTemplate.new {''} }
    result.object_id.should.equal template.object_id

    @cache.clear
    result = @cache.fetch('hello') { other = Tilt::StringTemplate.new {''} }
    result.object_id.should.equal other.object_id
  end
end
