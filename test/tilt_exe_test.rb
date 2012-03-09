require 'contest'
require 'fileutils'

# Test Strategy:
#
# These tests are setup to create a directory for each test method, named
# like 'PROJECT_DIR/tmp/METHOD_NAME'.  It is one of many ways to make a
# little sandbox for the tests, so that any created files easily accessible
# to the developer.  By default they will be removed in the teardown method.
# Set the environment variable KEEP_OUTPUTS=true to prevent their removal.
#
class TiltExeTest < Test::Unit::TestCase
  PROJECT_DIR = File.expand_path("../..", __FILE__)
  TMP_DIR = File.join(PROJECT_DIR, "tmp")
  TILT = "ruby -I'#{PROJECT_DIR}/lib' '#{PROJECT_DIR}/bin/tilt'"

  # A test-specific directory
  attr_accessor :method_dir

  # An accessor for the output of sh
  attr_accessor :output

  def setup
    super
    @pwd = Dir.pwd
    @method_dir = File.join(TMP_DIR, method_name)
    @output = nil

    FileUtils.rm_r(method_dir) if File.exists?(method_dir)
    FileUtils.mkdir_p(method_dir)
  end

  def teardown
    Dir.chdir(@pwd)
    unless ENV['KEEP_OUTPUTS'] == "true"
      FileUtils.rm_r(method_dir) if File.exists?(method_dir)
      FileUtils.rm_r(TMP_DIR)  if Dir["#{TMP_DIR}/*"].empty?
    end
    super
  end

  unless instance_methods.include?('method_name')
    # MiniTest uses __name__ instead of method_name
    def method_name
      __name__
    end
  end

  # Returns the command to execute the tilt exe.
  def tilt
    TILT
  end

  # Execute the shell command and assert the exit status.  Sets output.
  def sh(cmd, expected_status=0)
    @output = `#{cmd}`
    assert_equal expected_status, $?.exitstatus, "$ #{cmd}\n#{@output}"
  end

  # The path to a file under the method dir.
  def path(file)
    File.expand_path(file, method_dir)
  end

  # Create a file relative to the method dir with the specified content. 
  # Creates directories as needed.
  def prepare(file, content=nil)
    file = File.expand_path(file, method_dir)
    dir  = File.dirname(file)

    unless File.exists?(dir)
      FileUtils.mkdir_p(dir)
    end

    File.open(file, "w") {|io| io << content.to_s }
    file
  end

  #
  # -l, --list
  #

  %w{-l --list}.each do |opt|
    test "#{opt} prints template engines" do
      sh %{#{tilt} #{opt}}
      assert_match(/String\s+str/, output)
    end
  end

  #
  # -t, --type=<pattern>
  #

  %w{-t --type}.each do |opt|
    test "#{opt} sets template engine for template read via stdin" do
      sh %{echo "Answer: <%= 2 + 2 %>2" | #{tilt} #{opt} erb}
      assert_equal "Answer: 42\n", output
    end

    test "#{opt} prints error message on unknown type" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      sh %{#{tilt} -t 'unknown' '#{template}' 2>&1}, 1
      assert_equal "template engine not found for: \"unknown\" (see 'tilt --help')\n", output
    end
  end

  #
  # -y, --layout=<file>
  #

  %w{-y --layout}.each do |opt|
    test "#{opt} renders into template" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      layout   = prepare 'layout.erb', "Answer: <%= yield %>\n"

      sh %{#{tilt} #{opt} '#{layout}' '#{template}'}
      assert_equal "Answer: 42\n", output
    end

    test "#{opt} prints error message for non-file" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      assert_equal false, File.exists?('not_a_file')

      sh %{#{tilt} #{opt} not_a_file '#{template}' 2>&1}, 1
      assert_equal "not a file: \"not_a_file\" (see 'tilt --help')\n", output
    end
  end

  #
  # -f, --files
  #

  %w{-f --files}.each do |opt|
    test "#{opt} outputs file named as relative path to input file minus extname" do
      Dir.chdir(method_dir)
      template = prepare 'path/to/template.txt.erb', "Answer: <%= 2 + 2 %>2\n"

      sh %{#{tilt} #{opt} '#{template}'}
      assert_equal "path/to/template.txt\n", output
      assert_equal "Answer: 42\n", File.read('path/to/template.txt')
    end

    test "#{opt} uses input file basename for files not relative to self" do
      FileUtils.mkdir_p path('a')
      FileUtils.mkdir_p path('b')

      template = prepare 'a/path/to/template.txt.erb', "Answer: <%= 2 + 2 %>2\n"
      Dir.chdir path('b')

      sh %{#{tilt} #{opt} '#{template}'}
      assert_equal "template.txt\n", output
      assert_equal "Answer: 42\n", File.read(path("b/template.txt"))
    end

    test "#{opt} reads files from stdin on -" do
      Dir.chdir(method_dir)
      a = prepare 'a.erb', "A<%= 2 - 1 %>"
      b = prepare 'b.erb', "B<%= 1 + 1 %>"

      sh %{ls *.erb | #{tilt} #{opt} -}
      assert_equal "a\nb\n", output
      assert_equal "A1", File.read('a')
      assert_equal "B2", File.read('b')
    end

    test "#{opt} handles multiple files" do
      Dir.chdir(method_dir)
      a = prepare 'a.erb', "A<%= 2 - 1 %>"
      b = prepare 'b.erb', "B<%= 1 + 1 %>"
      c = prepare 'c.erb', "C<%= 2 + 1 %>"

      sh %{ls c.erb | #{tilt} #{opt} '#{a}' '#{b}' '-'}
      assert_equal "a\nb\nc\n", output
      assert_equal "A1", File.read('a')
      assert_equal "B2", File.read('b')
      assert_equal "C3", File.read('c')
    end
  end

  #
  # -o, --output-dir=<dir>
  #

  %w{-o --output-dir}.each do |opt|
    test "#{opt} sets the output dir for -f" do
      Dir.chdir(method_dir)
      template = prepare 'path/to/template.txt.erb', "Answer: <%= 2 + 2 %>2\n"

      sh %{#{tilt} #{opt} output -f '#{template}'}
      assert_equal "output/path/to/template.txt\n", output
      assert_equal "Answer: 42\n", File.read('output/path/to/template.txt')
    end
  end

  #
  # -i, --input-dir=<dir>
  #

  %w{-i --input-dir}.each do |opt|
    test "#{opt} sets base dir for relative paths" do
      FileUtils.mkdir_p path('a')
      FileUtils.mkdir_p path('b')

      template = prepare 'a/path/to/template.txt.erb', "Answer: <%= 2 + 2 %>2\n"
      Dir.chdir path('b')

      sh %{#{tilt} #{opt} '#{path('a')}' -f '#{template}'}
      assert_equal "path/to/template.txt\n", output
      assert_equal "Answer: 42\n", File.read(path("b/path/to/template.txt"))
    end
  end

  #
  # -a, --attrs=<file>
  #

  %w{-a --attrs}.each do |opt|
    test "#{opt} loads a YAML file for variables" do
      attrs = prepare('attrs.yml', "answer: 42")

      sh %{echo "Answer: <%= answer %>" | #{tilt} -t erb #{opt} '#{attrs}'}
      assert_equal "Answer: 42\n", output
    end

    test "#{opt} prints error for non-file" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      assert_equal false, File.exists?('not_a_file')

      sh %{#{tilt} #{opt} not_a_file '#{template}' 2>&1}, 1
      assert_equal "not a file: \"not_a_file\" (see 'tilt --help')\n", output
    end

    test "#{opt} prints error if YAML does not load to a hash" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      attrs = prepare('attrs.yml', "42")

      sh %{#{tilt} #{opt} '#{attrs}' '#{template}' 2>&1}, 1
      assert_equal "attrs must be a Hash, not 42 (see 'tilt --help')\n", output
    end
  end

  #
  # -D<name>=<value>
  #

  test "-D defines a variable" do
    sh %{echo "Answer: <%= 2 + n.to_i %>" | #{tilt} -t erb -Dn=40}
    assert_equal "Answer: 42\n", output
  end

  #
  # --vars=<ruby>
  #

  test "--vars evaluates ruby to variables" do
    sh %{echo "Answer: <%= 2 + n %>" | #{tilt} -t erb --vars "{:n=>40}"}
    assert_equal "Answer: 42\n", output
  end

  test "--vars prints error if ruby does not load to a hash" do
    template = prepare 'template.erb', "<%= 2 + 2 %>2"
    attrs = prepare('attrs.yml', "42")

    sh %{#{tilt} --vars '42' '#{template}' 2>&1}, 1
    assert_equal "vars must be a Hash, not 42 (see 'tilt --help')\n", output
  end

  #
  # -h, --help
  #

  %w{-h --help}.each do |opt|
    test "#{opt} prints help" do
      sh %{#{tilt} #{opt}}
      assert_match(/Usage: tilt/, output)
    end
  end

  #
  # tilt test
  #

  test "tilt renders input files to stdout" do
    template = prepare 'template.erb', "Answer: <%= 2 + 2 %>2\n"

    sh %{#{tilt} '#{template}'}
    assert_equal "Answer: 42\n", output
  end

  test "tilt reads from stdin on -" do
    sh %{echo "Answer: <%= 2 + 2 %>2" | #{tilt} -t erb -}
    assert_equal "Answer: 42\n", output
  end

  test "tilt renders multiple files" do
    a = prepare 'a.erb', "A<%= 2 - 1 %>"
    b = prepare 'b.erb', "B<%= 1 + 1 %>"

    sh %{echo "C<%= 2 + 1 %>" | #{tilt} -t erb '#{a}' '#{b}' -}
    assert_equal "A1B2C3\n", output
  end

  test "tilt prints error message for non-file" do
    assert_equal false, File.exists?('not_a_file')
    sh %{#{tilt} not_a_file 2>&1}, 1
    assert_equal "not a file: \"not_a_file\" (see 'tilt --help')\n", output

    sh %{#{tilt} '#{Dir.pwd}' 2>&1}, 1
    assert_equal "not a file: #{Dir.pwd.inspect} (see 'tilt --help')\n", output
  end

  test "tilt prints error message on unknown engine" do
    file = prepare 'unknown.engine'
    sh %{#{tilt} '#{file}' 2>&1}, 1
    assert_equal "template engine not found for: #{file.inspect} (see 'tilt --help')\n", output
  end

  #
  # documentation tests
  #

  test "documentation examples" do
    Dir.chdir(method_dir)
    # Process ERB template:
    #   $ echo "Answer: <%= 2 + 2 %>" | tilt -t erb
    #   Answer: 4
    sh %{echo "Answer: <%= 2 + 2 %>" | #{tilt} -t erb}
    assert_equal "Answer: 4\n", output

    # Process to output file:
    #   $ echo "Answer: <%= 2 + 2 %>" > foo.txt.erb
    #   $ tilt --files foo.txt.erb
    #   foo.txt
    #   $ cat foo.txt
    #   Answer: 4
    sh %{echo "Answer: <%= 2 + 2 %>" > foo.txt.erb}
    sh %{#{tilt} --files foo.txt.erb}
    assert_equal "foo.txt\n", output

    sh %{cat foo.txt}
    assert_equal "Answer: 4\n", output

    # Define variables:
    #   $ echo "Answer: <%= 2 + n %>" | tilt -t erb --vars="{:n=>40}"
    #   Answer: 42
    #   $ echo "Answer: <%= 2 + n.to_i %>" | tilt -t erb -Dn=40
    #   Answer: 42
    sh %{echo "Answer: <%= 2 + n %>" | #{tilt} -t erb --vars="{:n=>40}"}
    assert_equal "Answer: 42\n", output

    sh %{echo "Answer: <%= 2 + n.to_i %>" | #{tilt} -t erb -Dn=40}
    assert_equal "Answer: 42\n", output
  end
end