require 'tilt/template'

module Tilt
  # CoffeeScript template implementation.
  #
  # - http://coffeescript.org/
  #
  # CoffeeScript templates do not support object scopes, locals, or yield.
  #
  # All CoffeeScript files must be utf-8 encoded. The :default_encoding
  # option and system default encoding are ignored. When a non-utf-8 string
  # is provided via custom reader block, it is converted to utf-8 before
  # being passed to the Coffee compiler.
  class CoffeeScriptTemplate < Template
    self.default_mime_type = 'application/javascript'

    @@default_bare = false

    def self.default_bare
      @@default_bare
    end

    def self.default_bare=(value)
      @@default_bare = value
    end

    # DEPRECATED
    def self.default_no_wrap
      @@default_bare
    end

    # DEPRECATED
    def self.default_no_wrap=(value)
      @@default_bare = value
    end

    def self.engine_initialized?
      defined? ::CoffeeScript
    end

    def initialize_engine
      require_template_library 'coffee_script'
    end

    def prepare
      if !options.key?(:bare) and !options.key?(:no_wrap)
        options[:bare] = self.class.default_bare
      end

      # if string was given and its not utf-8, transcode it now
      data.encode! 'UTF-8' if data.respond_to?(:encode!)
    end

    def evaluate(scope, locals, &block)
      @output ||= CoffeeScript.compile(data, options)
    end

    # Override to set the @default_encoding to always be utf-8, ignoring the
    # :default_encoding option value.
    def read_template_file
      @default_encoding = 'UTF-8'
      super
    end
  end
end

