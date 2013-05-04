require 'tilt/mapping'

module Tilt
  VERSION = '2.0.0'

  @default_mapping = Mapping.new

  def self.default_mapping
    @default_mapping
  end

  def self.lazy_map
    default_mapping.lazy_map
  end

  # Register a template implementation by file extension.
  def self.register(template_class, *extensions)
    default_mapping.register(template_class, *extensions)
  end

  def self.register_lazy(class_name, file, *extensions)
    default_mapping.register_lazy(class_name, file, *extensions)
  end

  def self.prefer(template_class, *extensions)
    warn "Tilt.prefer has no longer any effect; use Tilt.register"
  end

  # Returns true when a template exists on an exact match of the provided file extension
  def self.registered?(ext)
    default_mapping.registered?(ext)
  end

  # Create a new template for the given file using the file's extension
  # to determine the the template mapping.
  def self.new(file, line=nil, options={}, &block)
    default_mapping.new(file, line, options, &block)
  end

  # Lookup a template class for the given filename or file
  # extension. Return nil when no implementation is found.
  def self.[](file)
    default_mapping[file]
  end

  # Extremely simple template cache implementation. Calling applications
  # create a Tilt::Cache instance and use #fetch with any set of hashable
  # arguments (such as those to Tilt.new):
  #   cache = Tilt::Cache.new
  #   cache.fetch(path, line, options) { Tilt.new(path, line, options) }
  #
  # Subsequent invocations return the already loaded template object.
  class Cache
    def initialize
      @cache = {}
    end

    def fetch(*key)
      @cache[key] ||= yield
    end

    def clear
      @cache = {}
    end
  end


  # Template Implementations ================================================

  # ERB
  register_lazy :ERBTemplate,    'tilt/erb',    'erb', 'rhtml'
  register_lazy :ErubisTemplate, 'tilt/erubis', 'erb', 'rhtml', 'erubis'

  # Markdown
  register_lazy :BlueClothTemplate,  'tilt/bluecloth', 'markdown', 'mkd', 'md'
  register_lazy :MarukuTemplate,     'tilt/maruku',    'markdown', 'mkd', 'md'
  register_lazy :KramdownTemplate,   'tilt/kramdown',  'markdown', 'mkd', 'md'
  register_lazy :RDiscountTemplate,  'tilt/rdiscount', 'markdown', 'mkd', 'md'
  register_lazy :RedcarpetTemplate,  'tilt/redcarpet', 'markdown', 'mkd', 'md'

  # Rest (sorted by name)
  register_lazy :AsciidoctorTemplate,  'tilt/asciidoc',  'ad', 'adoc', 'asciidoc'
  register_lazy :BuilderTemplate,      'tilt/builder',   'builder'
  register_lazy :CSVTemplate,          'tilt/csv',       'rcsv'
  register_lazy :CoffeeScriptTemplate, 'tilt/coffee',    'coffee'
  register_lazy :CreoleTemplate,       'tilt/creole',    'wiki', 'creole'
  register_lazy :EtanniTemplate,       'tilt/etanni',    'etn', 'etanni'
  register_lazy :HamlTemplate,         'tilt/haml',      'haml'
  register_lazy :LessTemplate,         'tilt/less',      'less'
  register_lazy :LiquidTemplate,       'tilt/liquid',    'liquid'
  register_lazy :MarkabyTemplate,      'tilt/markaby',   'mab'
  register_lazy :NokogiriTemplate,     'tilt/nokogiri',  'nokogiri'
  register_lazy :PlainTemplate,        'tilt/plain',     'html'
  register_lazy :RDocTemplate,         'tilt/rdoc',      'rdoc'
  register_lazy :RadiusTemplate,       'tilt/radius',    'radius'
  register_lazy :RedClothTemplate,     'tilt/redcloth',  'textile'
  register_lazy :SassTemplate,         'tilt/sass',      'sass'
  register_lazy :ScssTemplate,         'tilt/sass',      'scss'
  register_lazy :StringTemplate,       'tilt/string',    'str'
  register_lazy :WikiClothTemplate,    'tilt/wikicloth', 'wiki', 'mediawiki', 'mw'
  register_lazy :YajlTemplate,         'tilt/yajl',      'yajl'
end
