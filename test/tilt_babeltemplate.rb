require_relative 'test_helper'

begin
  require 'tilt/babel'

  describe 'tilt/babel' do
    it "registered for '.es6' files" do
      assert_equal Tilt::BabelTemplate, Tilt['es6']
    end

    it "registered for '.babel' files" do
      assert_equal Tilt::BabelTemplate, Tilt['babel']
    end

    it "registered for '.jsx' files" do
      assert_equal Tilt::BabelTemplate, Tilt['jsx']
    end

    it "basic ES6 features" do
      with_utf8_default_encoding do
        template = Tilt::BabelTemplate.new { "square = (x) => x * x" }
        assert_match "function", template.render
      end
    end

    it "JSX support" do
      with_utf8_default_encoding do
        template = Tilt::BabelTemplate.new { "<Awesome ness={true} />" }
        assert_match "React.createElement", template.render
      end
    end
  end
rescue LoadError => boom
  warn "Tilt::BabelTemplate (disabled)"
end

