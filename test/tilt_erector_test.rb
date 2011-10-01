require 'contest'
require 'tilt'

begin
  require 'erector'
  require 'erector'

  class ErectorTiltTest <  Test::Unit::TestCase
    def setup
      @block = lambda do |t|
        File.read(File.dirname(__FILE__) + "/#{t.file}")
      end
    end

    test "should be able to render a erector template with static html" do
      tilt = Tilt::ErectorTemplate.new("erector/erector.erector", &@block)
      assert_equal "hello from erector!", tilt.render
    end

    test "should use the contents of the template" do
      tilt = ::Tilt::ErectorTemplate.new("erector/erector_other_static.erector", &@block)
      assert_equal "_why?", tilt.render
    end

    test "should render from a string (given as data)" do
      tilt = ::Tilt::ErectorTemplate.new { "html do; end" }
      assert_equal "<html></html>", tilt.render
    end

    test "can be rendered more than once" do
      tilt = ::Tilt::ErectorTemplate.new { "html do; end" }
      3.times { assert_equal "<html></html>", tilt.render }
    end

    test "should evaluate a template file in the scope given" do
      scope = Object.new
      def scope.foo
        "bar"
      end

      tilt = ::Tilt::ErectorTemplate.new("erector/scope.erector", &@block)
      assert_equal "<li>bar</li>", tilt.render(scope)
    end

    # test "should pass locals to the template" do
    #   tilt = ::Tilt::ErectorTemplate.new("erector/locals.erector", &@block)
    #   assert_equal "<li>bar</li>", tilt.render(Object.new, { :foo => "bar" })
    # end

    test "should yield to the block given" do
      tilt = ::Tilt::ErectorTemplate.new("erector/yielding.erector", &@block)
      output = tilt.render(Object.new, {}) do
        text("Joe")
      end
      assert_equal "Hey Joe", output
    end

    test "should be able to render two templates in a row" do
      tilt = ::Tilt::ErectorTemplate.new("erector/render_twice.erector", &@block)
      assert_equal "foo", tilt.render
      assert_equal "foo", tilt.render
    end

    test "should retrieve a Tilt::ErectorTemplate when calling Tilt['hello.erector']" do
      assert_equal Tilt::ErectorTemplate, ::Tilt['./erector/erector.erector']
    end

    test "should return a new instance of the implementation class (when calling Tilt.new)" do
      assert ::Tilt.new(File.dirname(__FILE__) + "/erector/erector.erector").kind_of?(Tilt::ErectorTemplate)
    end

    test "should be able to evaluate block style templates" do
      tilt = Tilt::ErectorTemplate.new { |t| lambda { h1 "Hello World!" }}
      assert_equal "<h1>Hello World!</h1>", tilt.render
    end

    test "should pass locals to block style templates" do
      tilt = Tilt::ErectorTemplate.new { |t| lambda { h1 "Hello #{name}!" }}
      assert_equal "<h1>Hello _why!</h1>", tilt.render(nil, :name => "_why")
    end
  end

rescue LoadError => boom
  warn "Tilt::ErectorTemplate (disabled)"
end
