require_relative 'test_helper'

system('sigil -v')

if $?.success?
  require 'tilt/sigil'

  describe 'tilt/sigil' do
    it "registered for '.sigil' files" do
      assert_equal Tilt::SigilTemplate, Tilt['test.sigil']
    end

    it "loading and evaluating templates on #render" do
      template = Tilt::SigilTemplate.new { |t| "Hello World!" }
      assert_equal "Hello World!", template.render
    end

    it "can be rendered more than once" do
      template = Tilt::SigilTemplate.new { |t| "Hello World!" }
      3.times { assert_equal "Hello World!", template.render }
    end

    it "passing locals" do
      template = Tilt::SigilTemplate.new { 'Hey $name!' }
      assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
    end

    it "error message" do
      template = Tilt::SigilTemplate.new('test.sigil') { '{{undef_func}}' }
      begin
        template.render
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of RuntimeError, boom
        assert_equal 'template: test.sigil:1: function "undef_func" not defined', boom.message
      end
    end
  end
else
  warn "Tilt::SigilTemplate (disabled)"
end
