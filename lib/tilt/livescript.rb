require 'tilt/template'
require 'livescript'

module Tilt
  # LiveScript template implementation. See:
  # http://livescript.net/
  #
  # LiveScript templates do not support object scopes, locals, or yield.
  class LiveScriptTemplate < Template
    self.default_mime_type = 'application/javascript'

    @@default_bare = false

    def self.default_bare
      @@default_bare
    end

    def self.default_bare=(value)
      @@default_bare = value
    end

    def prepare
      if !options.key?(:bare)
        options[:bare] = self.class.default_bare
      end
    end

    def evaluate(scope, locals, &block)
      @output ||= LiveScript.compile(data, options)
    end

    def allows_script?
      false
    end
  end
end


