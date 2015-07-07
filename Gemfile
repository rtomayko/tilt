source 'https://rubygems.org'

gem 'yard', '~> 0.8.6'
gem 'ronn', '~> 0.7.3'
gem 'minitest', '~> 5.0'
gem 'contest'

gem 'rake'

group :primary do
  gem 'builder'
  gem 'erubis'
  gem 'haml', '>= 2.2.11', '< 4'
  gem 'less'
  gem 'coffee-script'
  gem 'markaby'
  gem 'sass'
end

group :secondary do
  gem 'creole'
  gem 'kramdown'
  gem 'rdoc', (ENV['RDOC_VERSION'] || '> 0')
  gem 'radius'
  gem 'asciidoctor', '>= 0.1.0'
  gem 'liquid'
  gem 'maruku'
  gem 'nokogiri' if RUBY_VERSION > '1.9.2'

  platform :ruby do
    gem 'wikicloth'
    gem 'yajl-ruby'
    gem 'redcarpet' if RUBY_VERSION > '1.8.7'
    gem 'rdiscount', '>= 2.1.6' if RUBY_VERSION != '1.9.2'
    gem 'RedCloth'
  end

  platform :mri do
    gem 'therubyracer'
    gem 'bluecloth' if ENV['BLUECLOTH']
  end
end

## WHY do I have to do this?!?
platform :rbx do
  gem 'rubysl'
end

