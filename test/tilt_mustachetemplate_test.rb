require 'contest'
require 'tilt'
require 'minitest/autorun'

begin
  describe "MustacheTemplate" do
    it "registered for '.mustache' files" do
      Tilt.mappings['mustache'].must_include Tilt::MustacheTemplate
    end

    it "loads and evaluates templates on #render" do
      template = Tilt::MustacheTemplate.new { |t| "Hello World!" }
      template.render.must_equal "Hello World!"
    end

    it "can be rendered more than once" do
      template = Tilt::MustacheTemplate.new { |t| "Hello World!" }
      3.times { template.render.must_equal "Hello World!" }
    end

    it "passing locals" do
      template = Tilt::MustacheTemplate.new { 'Hey {{ name }}!' }
      template.render(Object.new, :name => 'Joe').must_equal "Hey Joe!"
    end

    it "iterates over a collection" do
      users = [{"username" => "Joe"}, {"username" => "Jim"}, {"username" => "Jack"}]
      template = Tilt::MustacheTemplate.new { |t| users }

      template.render.must_match "Joe"
      template.render.must_match "Jim"
      template.render.must_match "Jack"
    end

    it "escapes characters, if they are not in {{{ }}}" do
      template = Tilt::MustacheTemplate.new { 'Hey {{ name }}!' }
      template.render(Object.new, :name => '<Joe>').must_equal "Hey &lt;Joe&gt;!"
    end

    it "does not escape characters, if they are in {{{ }}}" do
      template = Tilt::MustacheTemplate.new { 'Hey {{{ name }}}!' }
      template.render(Object.new, :name => '<Joe>').must_equal "Hey <Joe>!"
    end
  end

rescue LoadError => boom
  warn "Tilt::MustacheTemplate (disabled)"
end

__END__
<html>
<body>
  <h1>Hey {{ name }}!</h1>
  <p>{{{ fail }}}</p>
  <ul>
    {{# users }}
      <li>{{ username }}</li>
    {{/ users }}
  </ul>
</body>
</html>
