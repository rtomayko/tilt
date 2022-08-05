require_relative 'test_helper'

begin
  require 'tilt/sass'

  describe 'tilt/sass' do
    it "is registered for '.sass' files" do
      assert_equal Tilt::SassTemplate, Tilt['test.sass']
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::SassTemplate.new({ style: :compressed }) { |t| "#main\n  background-color: #0000f1" }
      assert_equal "#main{background-color:#0000f1}", template.render.chomp
    end

    it "can be rendered more than once" do
      template = Tilt::SassTemplate.new({ style: :compressed }) { |t| "#main\n  background-color: #0000f1" }
      3.times { assert_equal "#main{background-color:#0000f1}", template.render.chomp }
    end
  end

  describe 'tilt/sass (scss)' do
    it "is registered for '.scss' files" do
      assert_equal Tilt::ScssTemplate, Tilt['test.scss']
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::ScssTemplate.new({ style: :compressed }) { |t| "#main {\n  background-color: #0000f1;\n}" }
      assert_equal "#main{background-color:#0000f1}", template.render.chomp
    end

    it "can be rendered more than once" do
      template = Tilt::ScssTemplate.new({ style: :compressed }) { |t| "#main {\n  background-color: #0000f1;\n}" }
      3.times { assert_equal "#main{background-color:#0000f1}", template.render.chomp }
    end
  end

rescue LoadError => err
  raise err if ENV['FORCE_SASS']
  warn "Tilt::SassTemplate (disabled)"
end
