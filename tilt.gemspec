Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'tilt'
  s.version = '1.4.0'
  s.date = '2013-05-01'

  s.description = "Generic interface to multiple Ruby template engines"
  s.summary     = s.description
  s.license     = "MIT"

  s.authors = ["Ryan Tomayko"]
  s.email = "r@tomayko.com"

  # = MANIFEST =
  s.files = %w[
    CHANGELOG.md
    COPYING
    Gemfile
    HACKING
    README.md
    Rakefile
    TEMPLATES.md
    bin/tilt
    lib/tilt.rb
    lib/tilt/asciidoc.rb
    lib/tilt/builder.rb
    lib/tilt/coffee.rb
    lib/tilt/css.rb
    lib/tilt/csv.rb
    lib/tilt/erb.rb
    lib/tilt/etanni.rb
    lib/tilt/haml.rb
    lib/tilt/liquid.rb
    lib/tilt/markaby.rb
    lib/tilt/markdown.rb
    lib/tilt/nokogiri.rb
    lib/tilt/plain.rb
    lib/tilt/radius.rb
    lib/tilt/rdoc.rb
    lib/tilt/string.rb
    lib/tilt/template.rb
    lib/tilt/textile.rb
    lib/tilt/wiki.rb
    lib/tilt/yajl.rb
    test/contest.rb
    test/markaby/locals.mab
    test/markaby/markaby.mab
    test/markaby/markaby_other_static.mab
    test/markaby/render_twice.mab
    test/markaby/scope.mab
    test/markaby/yielding.mab
    test/tilt_asciidoctor_test.rb
    test/tilt_blueclothtemplate_test.rb
    test/tilt_buildertemplate_test.rb
    test/tilt_cache_test.rb
    test/tilt_coffeescripttemplate_test.rb
    test/tilt_compilesite_test.rb
    test/tilt_creoletemplate_test.rb
    test/tilt_csv_test.rb
    test/tilt_erbtemplate_test.rb
    test/tilt_erubistemplate_test.rb
    test/tilt_etannitemplate_test.rb
    test/tilt_fallback_test.rb
    test/tilt_hamltemplate_test.rb
    test/tilt_kramdown_test.rb
    test/tilt_lesstemplate_test.less
    test/tilt_lesstemplate_test.rb
    test/tilt_liquidtemplate_test.rb
    test/tilt_markaby_test.rb
    test/tilt_markdown_test.rb
    test/tilt_marukutemplate_test.rb
    test/tilt_nokogiritemplate_test.rb
    test/tilt_radiustemplate_test.rb
    test/tilt_rdiscounttemplate_test.rb
    test/tilt_rdoctemplate_test.rb
    test/tilt_redcarpettemplate_test.rb
    test/tilt_redclothtemplate_test.rb
    test/tilt_sasstemplate_test.rb
    test/tilt_stringtemplate_test.rb
    test/tilt_template_test.rb
    test/tilt_test.rb
    test/tilt_wikiclothtemplate_test.rb
    test/tilt_yajltemplate_test.rb
    tilt.gemspec
  ]
  # = MANIFEST =

  s.executables = ['tilt']
  s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

  s.homepage = "http://github.com/rtomayko/tilt/"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tilt", "--main", "Tilt"]
  s.require_paths = %w[lib]
  s.rubygems_version = '1.1.1'
end
