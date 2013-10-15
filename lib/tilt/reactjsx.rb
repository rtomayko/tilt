require 'tilt/template'
require 'react/jsx'

module Tilt
  # React JSX template implementation.
  # See: http://facebook.github.io/react/
  #
  # React JSX templates do not support object scopes, locals, or yield.
  class ReactJSXTemplate < Template
    self.default_mime_type = 'application/javascript'

    def prepare
    end

    def evaluate(scope, locals, &block)
      @output ||= React::JSX.compile(data)
    end
  end
end
