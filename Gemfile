source 'https://rubygems.org'

gemspec

gem 'rake'
gem 'minitest', '~> 5.0'

group :development do
  gem 'yard', '~> 0.9.0'
  gem 'ronn', '~> 0.7.3'
end

group :primary do
  gem 'builder'
  gem 'haml', '>= 4'
  gem 'erubis'
  gem 'markaby'

  case ENV['SASS_IMPLEMENTATION']
  when 'sass'
    gem 'sass'
  when 'sassc'
    gem 'sassc'
  else
    gem 'sass-embedded'
  end

  gem 'less'
  gem 'coffee-script'
  gem 'livescript'
  gem 'babel-transpiler'
  gem 'typescript-node'
end

platform :mri do
  gem 'duktape', '~> 1.3.0.6'
end

group :secondary do
  gem 'creole'
  gem 'kramdown'
  gem 'rdoc'
  gem 'radius'
  gem 'asciidoctor', '>= 0.1.0'
  gem 'liquid'
  gem 'maruku'
  gem 'pandoc-ruby'

  if RUBY_VERSION > '1.9.3'
    gem 'prawn', '>= 2.0.0'
    gem 'pdf-reader', '~> 1.3.3'
  end

  gem 'nokogiri'

  # Both rdiscount and bluecloth embeds Discount and loading
  # both at the same time causes strange issues.
  discount_gem = ENV["DISCOUNT_GEM"] || "rdiscount"
  raise "DISCOUNT_GEM must be set to 'rdiscount' or 'bluecloth'" if !%w[rdiscount bluecloth].include?(discount_gem)

  platform :ruby do
    gem 'wikicloth'
    gem 'rinku' # dependency for wikicloth for handling links

    gem 'yajl-ruby'
    gem 'redcarpet'
    gem 'rdiscount', '>= 2.1.6' if discount_gem == "rdiscount"
    gem 'RedCloth'
    gem 'commonmarker'
  end

  platform :mri do
    gem 'bluecloth' if discount_gem == "bluecloth"
  end
end

