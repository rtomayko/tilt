task :default => :spec

# SPECS =====================================================================

desc 'Generate test coverage report'
task :rcov do
  sh "rcov -Ilib:test test/*_test.rb"
end
desc 'Run specs with unit test style output'
task :test do |t|
  sh 'bacon -qa'
end

desc 'Run specs with story style output'
task :spec do |t|
  sh 'bacon -a'
end

# PACKAGING =================================================================

# load gemspec like github's gem builder to surface any SAFE issues.
Thread.new do
  require 'rubygems/specification'
  $spec = eval("$SAFE=3\n#{File.read('tilt.gemspec')}")
end.join

def package(ext='')
  "dist/tilt-#{$spec.version}" + ext
end

desc 'Build packages'
task :package => %w[.gem .tar.gz].map {|e| package(e)}

desc 'Build and install as local gem'
task :install => package('.gem') do
  sh "gem install #{package('.gem')}"
end

directory 'dist/'

file package('.gem') => %w[dist/ tilt.gemspec] + $spec.files do |f|
  sh "gem build tilt.gemspec"
  mv File.basename(f.name), f.name
end

file package('.tar.gz') => %w[dist/] + $spec.files do |f|
  sh "git archive --format=tar HEAD | gzip > #{f.name}"
end

desc 'Upload gem and tar.gz distributables to rubyforge'
task :release => [package('.gem'), package('.tar.gz')] do |t|
  sh <<-SH
    rubyforge add_release sinatra tilt #{$spec.version} #{package('.gem')} &&
    rubyforge add_file    sinatra tilt #{$spec.version} #{package('.tar.gz')}
  SH
end

# GEMSPEC ===================================================================

file 'tilt.gemspec' => FileList['{lib,test}/**','Rakefile'] do |f|
  # read spec file and split out manifest section
  spec = File.read(f.name)
  parts = spec.split("  # = MANIFEST =\n")
  # determine file list from git ls-files
  files = `git ls-files`.
    split("\n").sort.reject{ |file| file =~ /^\./ }.
    map{ |file| "    #{file}" }.join("\n")
  # piece file back together and write...
  parts[1] = "  s.files = %w[\n#{files}\n  ]\n"
  spec = parts.join("  # = MANIFEST =\n")
  spec.sub!(/s.date = '.*'/, "s.date = '#{Time.now.strftime("%Y-%m-%d")}'")
  File.open(f.name, 'w') { |io| io.write(spec) }
  puts "updated #{f.name}"
end

# DOC =======================================================================

# requires the hanna gem:
#   gem install mislav-hanna --source=http://gems.github.com
desc 'Build API documentation (doc/api)'
task 'rdoc' => 'rdoc/index.html' 
file 'rdoc/index.html' => FileList['lib/**/*.rb'] do |f|
  rm_rf 'rdoc'
  sh((<<-SH).gsub(/[\s\n]+/, ' ').strip)
  hanna
    --op doc/api
    --promiscuous
    --charset utf8
    --fmt html
    --inline-source
    --line-numbers
    --accessor option_accessor=RW
    --main Tilt
    --title 'Tilt API Documentation'
    #{f.prerequisites.join(' ')}
  SH
end
