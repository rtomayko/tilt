require 'contest'
require 'tmpdir'

class TiltExeTest < Test::Unit::TestCase
  PROJECT_DIR = File.expand_path("../..", __FILE__)
  TILT = "ruby -I'#{PROJECT_DIR}/lib' '#{PROJECT_DIR}/bin/tilt'"

  attr_accessor :test_dir
  attr_accessor :output

  def setup
    super
    @test_dir = File.join(Dir.tmpdir, method_name)
    FileUtils.rm_r(@test_dir) if File.exists?(@test_dir)
  end

  def tilt
    TILT
  end

  def sh(cmd, expected_status=0)
    @output = `#{cmd} 2>/dev/null`
    assert_equal expected_status, $?, "$ #{cmd}\n#{@output}"
  end

  def test_file(file_name)
    File.expand_path(file_name, test_dir)
  end

  def prepare_dir(dir_name)
    dir = test_file(dir_name)
    unless File.exists?(dir)
      FileUtils.mkdir_p(dir)
    end
    dir
  end

  def prepare(file_name, content=nil)
    file = test_file(file_name)
    dir  = File.dirname(file)

    unless File.exists?(dir)
      FileUtils.mkdir_p(dir)
    end

    File.open(file, "w") {|io| io << content.to_s }
    file
  end

  def content(file_name)
    file = test_file(file_name)
    File.exists?(file) ? File.read(file) : nil
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

  # -y, --layout=<file>    Use <file> as a layout template
  %w{-y --layout}.each do |opt|
    test "#{opt} renders into template" do
      template = prepare 'template.erb', "<%= 2 + 2 %>2"
      layout   = prepare 'layout.erb', "Answer: <%= yield %>\n"

      sh %{#{tilt} #{opt} '#{layout}' '#{template}'}
      assert_equal "Answer: 42\n", output
    end
  end

  # -f, --files            Output to files rather than stdout
  %w{-f --files}.each do |opt|
    test "#{opt} outputs to input file basename minus extname" do
      prepare_dir test_dir
      Dir.chdir(test_dir) do
        template = prepare 'template.txt.erb', "Answer: <%= 2 + 2 %>2\n"

        sh %{#{tilt} #{opt} '#{template}'}
        assert_equal "template.txt\n", output
        assert_equal "Answer: 42\n", File.read('template.txt')
      end
    end
  end

  # -i, --input-dir=<dir>  Use <dir> to determine relative paths for --files
  %w{-i --input-dir}.each do |opt|
    test "#{opt} sets base dir for relative paths under -o" do
      template   = prepare('input/template.txt.erb', "Answer: <%= 2 + 2 %>2\n")
      input_dir  = test_file('input')
      output_dir = test_file('output')

      sh %{#{tilt} #{opt} '#{input_dir}' -o '#{output_dir}' -f '#{template}'}
      assert_equal test_file('output/template.txt'), output.chomp("\n")
      assert_equal "Answer: 42\n", content('output/template.txt')
    end
  end

  # -o, --output-dir=<dir> Use <dir> as the output dir for --files
  %w{-o --output-dir}.each do |opt|
    test "#{opt} sets the output dir for -f" do
      template = prepare('template.txt.erb', "Answer: <%= 2 + 2 %>2\n")
      output_dir = test_file('output')

      sh %{#{tilt} #{opt} '#{output_dir}' -f '#{template}'}
      assert_equal test_file('output/template.txt'), output.chomp("\n")
      assert_equal "Answer: 42\n", content('output/template.txt')
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

  # -h, --help             Show this help message
  %w{-h --help}.each do |opt|
    test "#{opt} prints help" do
      sh %{#{tilt} #{opt}}
      assert_match(/Usage: tilt/, output)
    end
  end

  #
  # documentation tests
  #

  test "documentation examples" do
    prepare_dir test_dir
    Dir.chdir(test_dir) do
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
end