require 'rake/testtask'
task :default => [:test]

# SPECS =====================================================================

desc 'Run tests (default)'
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/*_test.rb']
  t.warning = false
end

# DOCUMENTATION =============================================================

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = [
      'lib/tilt.rb', 'lib/tilt/mapping.rb', 'lib/tilt/template.rb',
      '-',
      '*.md', 'docs/*.md',
    ]

    t.options <<
      '--no-private' <<
      '--protected' <<
      '-m' << 'markdown' <<
      '--asset' << 'docs/common.css:css/common.css'
  end
rescue LoadError
end

task :man do
  require 'ronn'
  ENV['RONN_MANUAL'] = "Tilt Manual"
  ENV['RONN_ORGANIZATION'] = "Tilt #{SPEC.version}"
  sh "ronn -w -s toc -r5 --markdown man/*.ronn"
end

# PACKAGING =================================================================

if defined?(Gem)
  SPEC = eval(File.read('tilt.gemspec'))

  def package(ext='')
    "pkg/tilt-#{SPEC.version}" + ext
  end

  desc 'Build packages'
  task :package => package('.gem')

  desc 'Build and install as local gem'
  task :install => package('.gem') do
    sh "gem install #{package('.gem')}"
  end

  directory 'pkg/'

  file package('.gem') => %w[pkg/ tilt.gemspec] + SPEC.files do |f|
    sh "gem build tilt.gemspec"
    mv File.basename(f.name), f.name
  end
end
