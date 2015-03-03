require 'tilt/template'
require 'pogo_script'

module Tilt
  # PogoScript template implementation. See:
  # http://pogoscript.org/
  #
  # PogoScript templates do not support object scopes, locals, or yield.
  class PogoScriptTemplate < Template
    self.default_mime_type = 'application/javascript'

    @@default_bare = false

    def self.default_bare
      @@default_bare
    end

    def self.default_bare=(value)
      @@default_bare = value
    end

    def self.engine_initialized?
      defined? ::PogoScript
    end

    def initialize_engine
      require_template_library 'pogo_script'
    end

    def prepare
      if !options.key?(:bare) and !options.key?(:no_wrap)
        options[:bare] = self.class.default_bare
      end
    end

    def evaluate(scope, locals, &block)
      @output ||= PogoScript.compile(data, options)
    end

    def allows_script?
      false
    end
  end
end
