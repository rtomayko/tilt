require 'bacon'
require 'tilt'

describe Tilt::StringTemplate do
  it "is registered for '.str' files" do
    Tilt['test.str'].should.equal Tilt::StringTemplate
  end

  it "compiles and evaluates the template on #render" do
    template = Tilt::StringTemplate.new { |t| "Hello World!" }
    template.render.should.equal "Hello World!"
  end

  it "supports locals" do
    template = Tilt::StringTemplate.new { 'Hey #{name}!' }
    template.render(Object.new, :name => 'Joe').should.equal "Hey Joe!"
  end

  it "is evaluated in the object scope provided" do
    template = Tilt::StringTemplate.new { 'Hey #{@name}!' }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    template.render(scope).should.equal "Hey Joe!"
  end

  it "evaluates template_source with yield support" do
    template = Tilt::StringTemplate.new { 'Hey #{yield}!' }
    template.render { 'Joe' }.should.equal "Hey Joe!"
  end

  it "renders multiline templates" do
    template = Tilt::StringTemplate.new { "Hello\nWorld!\n" }
    template.render.should.equal "Hello\nWorld!\n"
  end

  it "reports the file and line properly in backtraces without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::StringTemplate.new('test.str', 11) { data }
    begin
      template.render
      flunk 'should have raised an exception'
    rescue => boom
      boom.should.be.kind_of NameError
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      file.should.equal 'test.str'
      line.should.equal '13'
    end
  end

  it "reports the file and line properly in backtraces with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?<
    template = Tilt::StringTemplate.new('test.str', 1) { data }
    begin
      template.render(nil, :name => 'Joe', :foo => 'bar')
      flunk 'should have raised an exception'
    rescue => boom
      boom.should.be.kind_of RuntimeError
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      file.should.equal 'test.str'
      line.should.equal '6'
    end
  end
end

__END__
<html>
<body>
  <h1>Hey #{name}!</h1>


  <p>#{fail}</p>
</body>
</html>
