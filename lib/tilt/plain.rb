require 'tilt/template'


module Tilt
  # Raw Html (no template functionality).
  # Why do we need this pointless thing, you ask? 
  # - Because Tilt is the basis for dozens of file-based CMSes and static site generators
  # - (such as Hardwired, Nesta, Serve Jekyll, Ruhoh), which rely on tilt to provide all of their supported markup formats
  # And... plain HTML is an extremely common thing, especially for people migrating from Wordpress or other content management systems.
  # Despite it not offering any template functionality (it's not the only one, actually), I think it makes 
  # sense to have a null-op template available, and have a standardized file extension for it.
  class PlainTemplate < Template
    self.default_mime_type = 'text/html'

    def self.engine_initialized?
      true
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      @output ||= data
    end
  end
end
