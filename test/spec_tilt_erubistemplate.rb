require 'bacon'
require 'tilt'

begin
  require 'erubis'
  describe "Tilt::ErubisTemplate" do
    it "is registered for '.erubis' files" do
      Tilt['test.erubis'].should.equal Tilt::ErubisTemplate
      Tilt['test.html.erubis'].should.equal Tilt::ErubisTemplate
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::ErubisTemplate.new { |t| "Hello World!" }
      template.render.should.equal "Hello World!"
    end

    it "supports locals" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= name %>!' }
      template.render(Object.new, :name => 'Joe').should.equal "Hey Joe!"
    end

    it "is evaluated in the object scope provided" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= @name %>!' }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      template.render(scope).should.equal "Hey Joe!"
    end

    it "evaluates template_source with yield support" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= yield %>!' }
      template.render { 'Joe' }.should.equal "Hey Joe!"
    end

    it "reports the file and line properly in backtraces without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?<
      template = Tilt::ErubisTemplate.new('test.erubis', 11) { data }
      begin
        template.render
        flunk 'should have raised an exception'
      rescue => boom
        boom.should.be.kind_of NameError
        line = boom.backtrace.first
        file, line, meth = line.split(":")
        file.should.equal 'test.erubis'
        line.should.equal '13'
      end
    end

    it "reports the file and line properly in backtraces with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?<
      template = Tilt::ErubisTemplate.new('test.erubis', 1) { data }
      begin
        template.render(nil, :name => 'Joe', :foo => 'bar')
        flunk 'should have raised an exception'
      rescue => boom
        boom.should.be.kind_of RuntimeError
        line = boom.backtrace.first
        file, line, meth = line.split(":")
        file.should.equal 'test.erubis'
        line.should.equal '6'
      end
    end

    it "passes options to erubis" do
      template = Tilt::ErubisTemplate.new(nil, :pattern => '\{% %\}') { 'Hey {%= @name %}!' }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      template.render(scope).should.equal "Hey Joe!"
    end
  end
rescue LoadError => boom
  warn "Tilt::ErubisTemplate (disabled)\n"
end

__END__
<html>
<body>
  <h1>Hey <%= name %>!</h1>


  <p><% fail %></p>
</body>
</html>
