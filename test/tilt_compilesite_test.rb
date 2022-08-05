require_relative 'test_helper'

describe 'tilt compile site' do
  before do
    GC.start
  end

  _CompilingTemplate = Class.new(Tilt::Template) do
    def prepare
    end

    def precompiled_template(locals)
      @data.inspect
    end
  end

  _Scope = Class.new

  it "compiling template source to a method" do
    template = _CompilingTemplate.new { |t| "Hello World!" }
    template.render(_Scope.new)
    method = template.send(:compiled_method, [])
    assert_kind_of UnboundMethod, method
  end

  # This it attempts to surface issues with compiling templates from
  # multiple threads.
  it "using compiled templates from multiple threads" do
    template = _CompilingTemplate.new { 'template' }
    main_thread = Thread.current
    10.times do |i|
      threads =
        (1..50).map do |j|
          Thread.new {
            begin
              locals = { "local#{i}" => 'value' }
              res = template.render(self, locals)
              thread_id = Thread.current.object_id
              res = template.render(self, "local#{thread_id.abs.to_s}" => 'value')
            rescue => boom
              main_thread.raise(boom)
            end
          }
        end
      threads.each { |t| t.join }
    end
  end
end
