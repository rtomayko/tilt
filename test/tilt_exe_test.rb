require 'contest'
require 'fileutils'

class TiltExeTest < Test::Unit::TestCase
  PROJECT_DIR = File.expand_path("../..", __FILE__)
  TMP_DIR = File.join(PROJECT_DIR, "tmp")
  TILT = "ruby -I'#{PROJECT_DIR}/lib' '#{PROJECT_DIR}/bin/tilt'"

  attr_accessor :test_dir
  attr_accessor :output

  def setup
    super
    @pwd = Dir.pwd
    @test_dir = File.join(TMP_DIR, method_name)
    @output = nil

    FileUtils.rm_r(test_dir) if File.exists?(test_dir)
    FileUtils.mkdir_p(test_dir)
  end

  def teardown
    Dir.chdir(@pwd)
    unless ENV['KEEP_OUTPUTS'] == "true"
      FileUtils.rm_r(test_dir) if File.exists?(test_dir)
      FileUtils.rm_r(TMP_DIR)  if Dir["#{TMP_DIR}/*"].empty?
    end
    super
  end

  def tilt
    TILT
  end

  def sh(cmd, expected_status=0)
    @output = `#{cmd}`
    assert_equal expected_status, $?.exitstatus, "$ #{cmd}\n#{@output}"
  end

  def path(file)
    File.expand_path(file, test_dir)
  end

  def prepare(file, content=nil)
    file = File.expand_path(file, test_dir)
    dir  = File.dirname(file)

    unless File.exists?(dir)
      FileUtils.mkdir_p(dir)
    end

    File.open(file, "w") {|io| io << content.to_s }
    file
  end

  #
  # options tests
  #

  # -l, --list             List template engines + file patterns and exit
  test "-l prints template engines" do
    sh %{#{tilt} -l}
    assert_match(/String\s+str/, output)
  end

  test "--list prints template engines" do
    sh %{#{tilt} --list}
    assert_match(/String\s+str/, output)
  end

  # -t, --type=<pattern>   Use this template engine; required if no <file>
  test "-t sets template engine for template read via stdin" do
    sh %{echo "Answer: <%= 2 + 2 %>2" | #{tilt} -t erb}
    assert_equal "Answer: 42\n", output
  end

  test "--type sets template engine for template read via stdin" do
    sh %{echo "Answer: <%= 2 + 2 %>2" | #{tilt} --type erb}
    assert_equal "Answer: 42\n", output
  end

  %w{-t --type}.each do |opt|
    test "#{opt} prints error message on unknown type" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      sh %{#{tilt} -t 'unknown' '#{template}' 2>&1}, 1
      assert_equal "template engine not found for: \"unknown\" (see 'tilt --help')\n", output
    end
  end

  # -y, --layout=<file>    Use <file> as a layout template
  %w{-y --layout}.each do |opt|
    test "#{opt} renders into template" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      layout   = prepare 'layout.erb', "Answer: <%= yield %>\n"

      sh %{#{tilt} #{opt} '#{layout}' '#{template}'}
      assert_equal "Answer: 42\n", output
    end
  end

  %w{-y --layout}.each do |opt|
    test "#{opt} prints error message for non-file" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      assert_equal false, File.exists?('not_a_file')

      sh %{#{tilt} #{opt} not_a_file '#{template}' 2>&1}, 1
      assert_equal "not a file: \"not_a_file\" (see 'tilt --help')\n", output
    end
  end

  # -f, --files            Output to files rather than stdout
  %w{-f --files}.each do |opt|
    test "#{opt} outputs file named as relative path to input file minus extname" do
      Dir.chdir(test_dir)
      template = prepare 'path/to/template.txt.erb', "Answer: <%= 2 + 2 %>2\n"

      sh %{#{tilt} #{opt} '#{template}'}
      assert_equal "path/to/template.txt\n", output
      assert_equal "Answer: 42\n", File.read('path/to/template.txt')
    end
  end

  %w{-f --files}.each do |opt|
    test "#{opt} uses input file basename for files not relative to self" do
      FileUtils.mkdir_p path('a')
      FileUtils.mkdir_p path('b')

      template = prepare 'a/path/to/template.txt.erb', "Answer: <%= 2 + 2 %>2\n"
      Dir.chdir path('b')

      sh %{#{tilt} #{opt} '#{template}'}
      assert_equal "template.txt\n", output
      assert_equal "Answer: 42\n", File.read(path("b/template.txt"))
    end
  end

  %w{-f --files}.each do |opt|
    test "#{opt} reads files from stdin on -" do
      Dir.chdir(test_dir)
      a = prepare 'a.erb', "A<%= 2 - 1 %>"
      b = prepare 'b.erb', "B<%= 1 + 1 %>"

      sh %{ls *.erb | #{tilt} #{opt} -}
      assert_equal "a\nb\n", output
      assert_equal "A1", File.read('a')
      assert_equal "B2", File.read('b')
    end
  end

  %w{-f --files}.each do |opt|
    test "#{opt} handles multiple files" do
      Dir.chdir(test_dir)
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

  # -o, --output-dir=<dir> Use <dir> as the output dir for --files
  %w{-o --output-dir}.each do |opt|
    test "#{opt} sets the output dir for -f" do
      Dir.chdir(test_dir)
      template = prepare 'path/to/template.txt.erb', "Answer: <%= 2 + 2 %>2\n"

      sh %{#{tilt} #{opt} output -f '#{template}'}
      assert_equal "output/path/to/template.txt\n", output
      assert_equal "Answer: 42\n", File.read('output/path/to/template.txt')
    end
  end

  # -i, --input-dir=<dir>  Use <dir> to determine relative paths for --files
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

  # -a, --attrs=<file>     Load file as YAML and use for variables
  %w{-a --attrs}.each do |opt|
    test "#{opt} loads a YAML file for variables" do
      attrs = prepare('attrs.yml', "answer: 42")

      sh %{echo "Answer: <%= answer %>" | #{tilt} -t erb #{opt} '#{attrs}'}
      assert_equal "Answer: 42\n", output
    end
  end

  %w{-a --attrs}.each do |opt|
    test "#{opt} prints error for non-file" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      assert_equal false, File.exists?('not_a_file')

      sh %{#{tilt} #{opt} not_a_file '#{template}' 2>&1}, 1
      assert_equal "not a file: \"not_a_file\" (see 'tilt --help')\n", output
    end
  end

  %w{-a --attrs}.each do |opt|
    test "#{opt} prints error if YAML does not load to a hash" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      attrs = prepare('attrs.yml', "42")

      sh %{#{tilt} #{opt} '#{attrs}' '#{template}' 2>&1}, 1
      assert_equal "attrs must be a Hash, not 42 (see 'tilt --help')\n", output
    end
  end

  # -D<name>=<value>       Define variable <name> as <value>
  test "-D defines a variable" do
    sh %{echo "Answer: <%= 2 + n.to_i %>" | #{tilt} -t erb -Dn=40}
    assert_equal "Answer: 42\n", output
  end

  # --vars=<ruby>      Evaluate <ruby> to Hash and use for variables
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

  # -h, --help             Show this help message
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
    Dir.chdir(test_dir)
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