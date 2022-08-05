require_relative 'test_helper'

begin
  require 'tilt/typescript'

  describe 'tilt/typescript' do
    before do
      @ts = "var x:number = 5"
      @js = /var x = 5;\s*/
    end

    it "is registered for '.ts' files" do
      assert_equal Tilt::TypeScriptTemplate, Tilt['test.ts']
    end

    it "is registered for '.tsx' files" do
      assert_equal Tilt::TypeScriptTemplate, Tilt['test.tsx']
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::TypeScriptTemplate.new { @ts }
      assert_match @js, template.render
    end

    it "supports source map" do
      template = Tilt::TypeScriptTemplate.new(inlineSourceMap: true)  { @ts }
      assert_match %r(sourceMappingURL), template.render
    end

    it "can be rendered more than once" do
      template = Tilt::TypeScriptTemplate.new { @ts }
      3.times { assert_match @js, template.render }
    end
  end
rescue LoadError
  warn "Tilt::TypeScriptTemplate (disabled)"
end
