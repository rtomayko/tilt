require_relative 'test_helper'

begin
  require 'tilt/rdoc'

  describe 'tilt/rdoc' do
    it "is registered for '.rdoc' files" do
      assert_equal Tilt::RDocTemplate, Tilt['test.rdoc']
    end

    it "preparing and evaluating the template with #render" do
      template = Tilt::RDocTemplate.new { |t| "= Hello World!" }
      result = template.render.strip
      assert_match %r(<h1), result
      assert_match %r(>Hello World!<), result
    end

    it "can be rendered more than once" do
      template = Tilt::RDocTemplate.new { |t| "= Hello World!" }
      3.times do
        result = template.render.strip
        assert_match %r(<h1), result
        assert_match %r(>Hello World!<), result
      end
    end
  end
rescue LoadError => boom
  warn "Tilt::RDocTemplate (disabled) [#{boom}]"
end
