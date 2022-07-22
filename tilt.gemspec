Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'tilt'
  s.version = '2.0.11'
  s.date = '2022-07-22'

  s.description = "Generic interface to multiple Ruby template engines"
  s.summary     = s.description
  s.license     = "MIT"

  s.authors = ["Ryan Tomayko"]
  s.email = "r@tomayko.com"

  # = MANIFEST =
  s.files = %w[
    COPYING
    bin/tilt
    lib/tilt.rb
    lib/tilt/asciidoc.rb
    lib/tilt/babel.rb
    lib/tilt/bluecloth.rb
    lib/tilt/builder.rb
    lib/tilt/coffee.rb
    lib/tilt/commonmarker.rb
    lib/tilt/creole.rb
    lib/tilt/csv.rb
    lib/tilt/dummy.rb
    lib/tilt/erb.rb
    lib/tilt/erubi.rb
    lib/tilt/erubis.rb
    lib/tilt/etanni.rb
    lib/tilt/haml.rb
    lib/tilt/kramdown.rb
    lib/tilt/less.rb
    lib/tilt/liquid.rb
    lib/tilt/livescript.rb
    lib/tilt/mapping.rb
    lib/tilt/markaby.rb
    lib/tilt/maruku.rb
    lib/tilt/nokogiri.rb
    lib/tilt/pandoc.rb
    lib/tilt/plain.rb
    lib/tilt/prawn.rb
    lib/tilt/radius.rb
    lib/tilt/rdiscount.rb
    lib/tilt/rdoc.rb
    lib/tilt/redcarpet.rb
    lib/tilt/redcloth.rb
    lib/tilt/rst-pandoc.rb
    lib/tilt/sass.rb
    lib/tilt/sigil.rb
    lib/tilt/string.rb
    lib/tilt/template.rb
    lib/tilt/typescript.rb
    lib/tilt/wikicloth.rb
    lib/tilt/yajl.rb
  ]
  # = MANIFEST =

  s.executables = ['tilt']

  s.homepage = "https://github.com/rtomayko/tilt/"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tilt", "--main", "Tilt"]
  s.require_paths = %w[lib]
  s.rubygems_version = '1.1.1'
end
