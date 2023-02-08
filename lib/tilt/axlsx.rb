require 'tilt/template'
require 'axlsx'

module Tilt
  class AxlsxTemplate < Template
    self.default_mime_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

    def prepare
    end

    def precompiled_preamble(locals)
      'xlsx_package = ::Axlsx::Package.new'
    end

    def precompiled_postamble(locals)
      'xlsx_package.to_stream.string'
    end

    def precompiled_template(locals)
      data.to_str
    end
  end
end
