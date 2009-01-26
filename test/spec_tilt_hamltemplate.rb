require 'bacon'
require 'tilt'

begin
  class ::MockError < NameError
  end

  require 'haml'
  describe "Tilt::HamlTemplate" do
    it "is registered for '.haml' files" do
      Tilt['test.haml'].should.equal Tilt::HamlTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::HamlTemplate.new { |t| "%p Hello World!" }
      template.render.should.equal "<p>Hello World!</p>\n"
    end

    it "supports locals" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + name + '!'" }
      template.render(Object.new, :name => 'Joe').should.equal "<p>Hey Joe!</p>\n"
    end

    it "is evaluated in the object scope provided" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + @name + '!'" }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      template.render(scope).should.equal "<p>Hey Joe!</p>\n"
    end

    it "evaluates template_source with yield support" do
      template = Tilt::HamlTemplate.new { "%p= 'Hey ' + yield + '!'" }
      template.render { 'Joe' }.should.equal "<p>Hey Joe!</p>\n"
    end

    it "reports the file and line properly in backtraces without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?%
      template = Tilt::HamlTemplate.new('test.haml', 10) { data }
      begin
        template.render
        fail 'should have raised an exception'
      rescue => boom
        boom.should.be.kind_of NameError
        line = boom.backtrace.first
        file, line, meth = line.split(":")
        file.should.equal 'test.haml'
        line.should.equal '12'
      end
    end

    it "reports the file and line properly in backtraces with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?%
      template = Tilt::HamlTemplate.new('test.haml') { data }
      begin
        res = template.render(Object.new, :name => 'Joe', :foo => 'bar')
      rescue => boom
        boom.should.be.kind_of ::MockError
        line = boom.backtrace.first
        file, line, meth = line.split(":")
        file.should.equal 'test.haml'
        line.should.equal '5'
      end
    end
  end

rescue LoadError => boom
  warn "Tilt::HamlTemplate (disabled)\n"
end

__END__
%html
  %body
    %h1= "Hey #{name}"

    = raise MockError

    %p we never get here
