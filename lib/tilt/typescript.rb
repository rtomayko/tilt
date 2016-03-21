require 'tilt/template'
require 'typescript-node'

module Tilt
  class TypeScriptTemplate < Template
    self.default_mime_type = 'application/javascript'

    def prepare
    end

    def evaluate(scope, locals, &block)
      @output ||= TypeScript::Node.compile(data, '--target', 'ES5')
    end
  end
end
