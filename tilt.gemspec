Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'tilt'
  s.version = '0.3'
  s.date = '2009-11-06'

  s.description = "Generic interface to multiple Ruby template engines"
  s.summary     = s.description

  s.authors = ["Ryan Tomayko"]
  s.email = "r@tomayko.com"

  # = MANIFEST =
  s.files = %w[
    COPYING
    README.md
    Rakefile
    TEMPLATES.md
    bin/tilt
    lib/tilt.rb
    test/.bacon
    test/spec_tilt.rb
    test/spec_tilt_buildertemplate.rb
    test/spec_tilt_erbtemplate.rb
    test/spec_tilt_erubistemplate.rb
    test/spec_tilt_hamltemplate.rb
    test/spec_tilt_liquid_template.rb
    test/spec_tilt_mustachetemplate.rb
    test/spec_tilt_rdiscount.rb
    test/spec_tilt_sasstemplate.rb
    test/spec_tilt_stringtemplate.rb
    test/spec_tilt_template.rb
    tilt.gemspec
  ]
  # = MANIFEST =

  s.test_files = s.files.select {|path| path =~ /^test\/spec_.*.rb/}
  s.add_development_dependency 'contest'
  s.add_development_dependency 'builder'
  s.add_development_dependency 'erubis'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'mustache'
  s.add_development_dependency 'rdiscount'
  s.add_development_dependency 'liquid'

  s.extra_rdoc_files = %w[COPYING]

  s.has_rdoc = true
  s.homepage = "http://github.com/rtomayko/tilt/"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tilt", "--main", "Tilt"]
  s.require_paths = %w[lib]
  s.rubyforge_project = 'wink'
  s.rubygems_version = '1.1.1'
end
