module Tilt
  class CSVTemplate < Template
    self.default_mime_type = 'text/csv'

    def self.engine_initialized?
      engine
    end

    def self.engine
      if RUBY_VERSION >= '1.9.0'
        ::CSV
      else
        ::FasterCSV
      end
    end

    def initialize_engine
      if RUBY_VERSION >= '1.9.0'
        require_template_library 'csv'
      else
        require_template_library 'fastercsv'
      end
    end

    def prepare
      @code =<<-RUBY
        #{self.class.engine}.generate do |csv|
          #{data}
        end
      RUBY
    end

    def precompiled_template(locals)
      @code
    end

    def precompiled(locals)
      source, offset = super
      [source, offset + 1]
    end

  end
end