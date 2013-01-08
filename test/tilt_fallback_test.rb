require 'contest'
require 'tilt'

class TiltFallbackTest < Test::Unit::TestCase
  class Tilt::FailTemplate  < Tilt::Template
    def self.engine_initialized?; false end
    def prepare;                        end

    def initialize_engine
      raise LoadError, "can't load #{self.class}"
    end
  end

  class Tilt::WinTemplate < Tilt::Template
    def self.engine_initialized?; true end
    def prepare;                       end
  end

  class Tilt::FailTemplate2 < Tilt::FailTemplate; end
  class Tilt::WinTemplate2  < Tilt::WinTemplate;  end

  def set_ivar(obj, name, value)
    obj.instance_variable_set("@#{name}", value)
  end

  def clear_ivar(obj, name)
    ivar = "@#{name}"
    value = obj.instance_variable_get(ivar)
  ensure
    obj.instance_variable_set(ivar, value.dup.clear)
  end

  setup do
    # Make sure every test have no mappings.
    @p = clear_ivar(Tilt, :preferred_mappings)
    @t = clear_ivar(Tilt, :template_mappings)
  end

  teardown do
    set_ivar(Tilt, :preferred_mappings, @p)
    set_ivar(Tilt, :template_mappings, @t)
  end

  test "returns nil on unregistered extensions" do
    template = Tilt["md"]
    assert_equal nil, template
  end

  test "returns the last registered template" do
    Tilt.register("md", Tilt::WinTemplate)
    Tilt.register("md", Tilt::WinTemplate2)

    template = Tilt["md"]
    assert_equal Tilt::WinTemplate2, template
  end

  test "returns the last registered working template" do
    Tilt.register("md", Tilt::WinTemplate)
    Tilt.register("md", Tilt::FailTemplate)

    template = Tilt["md"]
    assert_equal Tilt::WinTemplate, template
  end

  test "if every template fails, raise the exception from the first template" do
    Tilt.register("md", Tilt::FailTemplate)
    Tilt.register("md", Tilt::FailTemplate2)

    exc = assert_raise(LoadError) { Tilt["md"] }
    assert_match /FailTemplate2/, exc.message
  end

  test ".prefer should also register the template" do
    Tilt.prefer(Tilt::WinTemplate, "md")
    assert Tilt.registered?("md")
  end

  test ".prefer always win" do
    Tilt.register("md", Tilt::FailTemplate)
    Tilt.register("md", Tilt::WinTemplate)
    Tilt.prefer(Tilt::FailTemplate, "md")

    template = Tilt["md"]
    assert_equal Tilt::FailTemplate, template
  end

  test ".prefer accepts multiple extensions" do
    extensions = %w[md mkd markdown]
    Tilt.prefer(Tilt::FailTemplate, *extensions)

    extensions.each do |ext|
      template = Tilt[ext]
      assert_equal Tilt::FailTemplate, template
    end
  end

  test ".prefer with no extension should use already registered extensions" do
    extensions = %w[md mkd markdown]

    extensions.each do |ext|
      Tilt.register(ext, Tilt::FailTemplate)
      Tilt.register(ext, Tilt::WinTemplate)
    end

    Tilt.prefer(Tilt::FailTemplate)

    extensions.each do |ext|
      template = Tilt[ext]
      assert_equal Tilt::FailTemplate, template
    end
  end

  test ".prefer should only override extensions the preferred library is registered for"  do
    Tilt.register("md", Tilt::WinTemplate)
    Tilt.register("mkd", Tilt::FailTemplate)
    Tilt.register("mkd", Tilt::WinTemplate)
    Tilt.prefer(Tilt::FailTemplate)
    assert_equal Tilt::FailTemplate, Tilt["mkd"]
    assert_equal Tilt::WinTemplate, Tilt["md"]
  end
end

