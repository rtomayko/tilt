require_relative 'test_helper'

describe 'tilt metadata' do
  _MyTemplate = Class.new(Tilt::Template) do
    metadata[:global] = 1
    self.default_mime_type = 'text/html'

    def prepare
    end

    def allows_script?
      true
    end
  end

  it "global metadata" do
    assert _MyTemplate.metadata
    assert_equal 1, _MyTemplate.metadata[:global]
  end

  it "instance metadata" do
    tmpl = _MyTemplate.new { '' }
    assert_equal 1, tmpl.metadata[:global]
  end

  it "gracefully handles default_mime_type" do
    assert_equal 'text/html', _MyTemplate.metadata[:mime_type]
  end

  it "still allows .default_mime_type" do
    assert_equal 'text/html', _MyTemplate.default_mime_type
  end

  it "gracefully handles allows_script?" do
    tmpl = _MyTemplate.new { '' }
    assert_equal true, tmpl.metadata[:allows_script]
  end
end
