require_relative 'test_helper'

begin
  require 'tilt/wikicloth'

  describe 'tilt/wikicloth' do
    it "is registered for '.mediawiki' files" do
      assert_equal Tilt::WikiClothTemplate, Tilt['test.mediawiki']
    end

    it "is registered for '.mw' files" do
      assert_equal Tilt::WikiClothTemplate, Tilt['test.mw']
    end

    it "is registered for '.wiki' files" do
      assert_equal Tilt::WikiClothTemplate, Tilt['test.wiki']
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::WikiClothTemplate.new { |t| "= Hello World! =" }
      assert_match(/<h1>.*Hello World!.*<\/h1>/m, template.render)
    end

    it "can be rendered more than once" do
      template = Tilt::WikiClothTemplate.new { |t| "= Hello World! =" }
      3.times { assert_match(/<h1>.*Hello World!.*<\/h1>/m, template.render) }
    end
  end
rescue LoadError
  warn "Tilt::WikiClothTemplate (disabled)"
end
