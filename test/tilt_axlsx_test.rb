require_relative 'test_helper'

begin
  require 'tilt/axlsx'
  require 'roo'

  describe 'tilt/axlsx' do
    before do
      @template = Tilt::AxlsxTemplate.new do |t| 
        <<~TEMPLATE
          wb = xlsx_package.workbook
          wb.add_worksheet(name: 'Users') do |sheet|
            sheet.add_row ["id", "email"]
          end
        TEMPLATE
      end
    end

    it "is registered for '.xlsx' files" do
      assert_equal Tilt::AxlsxTemplate, Tilt['test.xlsx']
    end

    it "is registered for '.axlsx' files" do
      assert_equal Tilt::AxlsxTemplate, Tilt['test.axlsx']
    end

    it "compiles and evaluates the template on #render" do
      output = @template.render
      wb = Roo::Spreadsheet.open(StringIO.new(output), extension: :xlsx)
      assert_equal ["Users"], wb.sheets
      assert_equal ["id", "email"], wb.sheet(0).row(1)
    end

    it "can be rendered more than once" do
      3.times do 
        output = @template.render
        wb = Roo::Spreadsheet.open(StringIO.new(output), extension: :xlsx)
        assert_equal ["Users"], wb.sheets
      end
    end
  end
rescue LoadError
  warn "Tilt::AxlsxTemplate (disabled)"
end
