source "http://rubygems.org"

gem 'yard', '~> 0.8.6'
gem 'minitest', '~> 5.0'

gem 'rake'

group :engines do
  gem 'asciidoctor', '>= 0.1.0'
  gem 'builder'
  gem 'coffee-script'
  gem 'livescript'
  gem 'contest'
  gem 'creole'
  gem 'erubis'
  gem 'haml', '>= 2.2.11', '< 4'
  gem 'kramdown'
  gem 'less'
  gem 'liquid'
  gem 'markaby'
  gem 'maruku'
  gem 'nokogiri'
  gem 'radius'
  gem 'sass'
  gem 'wikicloth'
  gem 'rdoc', (ENV['RDOC_VERSION'] || '> 0')

  platform :ruby do
    gem 'yajl-ruby'
    gem 'redcarpet'
    gem 'rdiscount' if RUBY_VERSION != '1.9.2'
    gem 'RedCloth'
  end

  platform :mri do
    gem 'therubyracer'
    gem 'bluecloth'
  end
end

