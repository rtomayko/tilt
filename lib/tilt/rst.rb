require 'tilt/template'
require 'pandoc-ruby'

module Tilt
  # Pandoc reStructuredText implementation. See:
  # http://pandoc.org/
  # Use PandocTemplate and specify input format
  class RstTemplate < PandocTemplate
    def pandoc_options
      options.merge!(f: 'rst')
      super
    end
  end
end
