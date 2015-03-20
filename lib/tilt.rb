require 'tilt/mapping'
require 'tilt/template'

# Namespace for Tilt. This module is not intended to be included anywhere.
module Tilt
  # Current version.
  VERSION = '2.0.1'

  @default_mapping = Mapping.new

  # @return [Tilt::Mapping] the main mapping object
  def self.default_mapping
    @default_mapping
  end

  # @private
  def self.lazy_map
    default_mapping.lazy_map
  end

  # @see Tilt::Mapping#register
  def self.register(template_class, *extensions)
    default_mapping.register(template_class, *extensions)
  end

  # @see Tilt::Mapping#register_lazy
  def self.register_lazy(class_name, file, *extensions)
    default_mapping.register_lazy(class_name, file, *extensions)
  end

  # @deprecated Use {register} instead.
  def self.prefer(template_class, *extensions)
    register(template_class, *extensions)
  end

  # @see Tilt::Mapping#registered?
  def self.registered?(ext)
    default_mapping.registered?(ext)
  end

  # @see Tilt::Mapping#new
  def self.new(file, line=nil, options={}, &block)
    default_mapping.new(file, line, options, &block)
  end

  # @see Tilt::Mapping#[]
  def self.[](file)
    default_mapping[file]
  end

  # @see Tilt::Mapping#template_for
  def self.template_for(file)
    default_mapping.template_for(file)
  end

  # @see Tilt::Mapping#templates_for
  def self.templates_for(file)
    default_mapping.templates_for(file)
  end

  # @see Tilt::Mapping#preload
  def self.preload
    default_mapping.preload
  end

  # @return the template object that is currently rendering.
  #
  # @example
  #   tmpl = Tilt['index.erb'].new { '<%= Tilt.current_template %>' }
  #   tmpl.render == tmpl.to_s
  #
  # @note This is currently an experimental feature and might return nil
  #   in the future.
  def self.current_template
    Thread.current[:tilt_current_template]
  end

  # Extremely simple template cache implementation. Calling applications
  # create a Tilt::Cache instance and use #fetch with any set of hashable
  # arguments (such as those to Tilt.new):
  #
  #     cache = Tilt::Cache.new
  #     cache.fetch(path, line, options) { Tilt.new(path, line, options) }
  #
  # Subsequent invocations return the already loaded template object.
  class Cache
    def initialize
      @cache = {}
    end

    # @see Cache
    def fetch(*key)
      @cache.fetch(key) do
        @cache[key] = yield
      end
    end

    # Clears the cache.
    def clear
      @cache = {}
    end
  end


  # Template Implementations ================================================

  # ERB
  register_lazy :ERBTemplate,    'tilt/erb',    'erb', 'rhtml', :preload_if => :ERB
  register_lazy :ErubisTemplate, 'tilt/erubis', 'erb', 'rhtml', 'erubis', :preload_if => :Erubis

  # Markdown
  register_lazy :BlueClothTemplate,  'tilt/bluecloth', 'markdown', 'mkd', 'md', :preload_if => :BlueCloth
  register_lazy :MarukuTemplate,     'tilt/maruku',    'markdown', 'mkd', 'md', :preload_if => :Maruku
  register_lazy :KramdownTemplate,   'tilt/kramdown',  'markdown', 'mkd', 'md', :preload_if => :Kramdown
  register_lazy :RDiscountTemplate,  'tilt/rdiscount', 'markdown', 'mkd', 'md', :preload_if => :RDiscount
  register_lazy :RedcarpetTemplate,  'tilt/redcarpet', 'markdown', 'mkd', 'md', :preload_if => :Redcarpet

  # Rest (sorted by name)
  register_lazy :AsciidoctorTemplate,  'tilt/asciidoc',  'ad', 'adoc', 'asciidoc', :preload_if => :Asciidoctor
  register_lazy :BuilderTemplate,      'tilt/builder',   'builder', :preload_if => :Builder
  register_lazy :CSVTemplate,          'tilt/csv',       'rcsv', :preload_if => [:CSV, :FasterCSV]
  register_lazy :CoffeeScriptTemplate, 'tilt/coffee',    'coffee', :preload_if => :CoffeeScript
  register_lazy :CreoleTemplate,       'tilt/creole',    'wiki', 'creole', :preload_if => :Creole
  register_lazy :EtanniTemplate,       'tilt/etanni',    'etn', 'etanni'
  register_lazy :HamlTemplate,         'tilt/haml',      'haml', :preload_if => :Haml
  register_lazy :LessTemplate,         'tilt/less',      'less', :preload_if => :Less
  register_lazy :LiquidTemplate,       'tilt/liquid',    'liquid', :preload_if => :Liquid
  register_lazy :MarkabyTemplate,      'tilt/markaby',   'mab', :preload_if => :Markaby
  register_lazy :NokogiriTemplate,     'tilt/nokogiri',  'nokogiri', :preload_if => :Nokogiri
  register_lazy :PlainTemplate,        'tilt/plain',     'html'
  register_lazy :RDocTemplate,         'tilt/rdoc',      'rdoc', :preload_if => :RDoc
  register_lazy :RadiusTemplate,       'tilt/radius',    'radius', :preload_if => :Radius
  register_lazy :RedClothTemplate,     'tilt/redcloth',  'textile', :preload_if => :RedCloth
  register_lazy :SassTemplate,         'tilt/sass',      'sass', :preload_if => :Sass
  register_lazy :ScssTemplate,         'tilt/sass',      'scss', :preload_if => :Sass
  register_lazy :StringTemplate,       'tilt/string',    'str'
  register_lazy :WikiClothTemplate,    'tilt/wikicloth', 'wiki', 'mediawiki', 'mw', :preload_if => :WikiCloth
  register_lazy :YajlTemplate,         'tilt/yajl',      'yajl', :preload_if => :Yajl

  # External template engines
  register_lazy 'Slim::Template',            'slim',            'slim'
  register_lazy 'Tilt::HandlebarsTemplate',  'tilt/handlebars', 'handlebars', 'hbs'
  register_lazy 'Tilt::OrgTemplate',         'org-ruby',        'org'
end
