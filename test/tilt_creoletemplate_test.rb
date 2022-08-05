require_relative 'test_helper'

begin
  require 'tilt/creole'

  describe 'tilt/creole' do
    it "is registered for '.creole' files" do
      assert_equal Tilt::CreoleTemplate, Tilt['test.creole']
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::CreoleTemplate.new { |t| "= Hello World!" }
      assert_equal "<h1>Hello World!</h1>", template.render
    end

    it "can be rendered more than once" do
      template = Tilt::CreoleTemplate.new { |t| "= Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>", template.render }
    end
  end
rescue LoadError
  warn "Tilt::CreoleTemplate (disabled)"
end
