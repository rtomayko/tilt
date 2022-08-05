require_relative 'test_helper'

begin
  require 'tilt/kramdown'

  describe 'tilt/kramdown' do
    it "preparing and evaluating templates on #render" do
      template = Tilt::KramdownTemplate.new { |t| "# Hello World!" }
      assert_equal '<h1 id="hello-world">Hello World!</h1>', template.render.strip
    end

    it "can be rendered more than once" do
      template = Tilt::KramdownTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal '<h1 id="hello-world">Hello World!</h1>', template.render.strip }
    end
  end
rescue LoadError
  warn "Tilt::KramdownTemplate (disabled)"
end
