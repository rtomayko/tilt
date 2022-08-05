require_relative 'test_helper'

begin
  require 'tilt/prawn'
  require 'pdf-reader'

  _PdfOutput = Class.new do
    def initialize(pdf_raw)
      @reader = PDF::Reader.new(StringIO.new(pdf_raw))
    end
    
    def text
      @reader.pages.map(&:text).join
    end
    
    def page_attributes(page_num=1)
      @reader.page(page_num).attributes
    end
  end

  describe 'tilt/prawn' do
    it "is registered for '.prawn' files" do
      assert_equal Tilt::PrawnTemplate, Tilt['test.prawn']
    end

    it "compiles and evaluates the template on #render" do
      template = Tilt::PrawnTemplate.new { |t| "pdf.text \"Hello PDF!\"" }
      output   = _PdfOutput.new(template.render)
      assert_includes output.text, "Hello PDF!"
    end
    
    it "can be rendered more than once" do
      template = Tilt::PrawnTemplate.new { |t| "pdf.text \"Hello PDF!\"" }
      3.times do
        output   = _PdfOutput.new(template.render)
        assert_includes output.text, "Hello PDF!"
      end
    end
    
    it "loads the template from a file and renders it correctly" do
      template = Tilt::PrawnTemplate.new("test/tilt_prawntemplate.prawn")
      output   = _PdfOutput.new(template.render)
      assert_includes output.text, "Hello Template!"
    end
    
    it "loads the template from a file and can be rendered more than once" do
      template = Tilt::PrawnTemplate.new("test/tilt_prawntemplate.prawn")
      3.times do
        output   = _PdfOutput.new(template.render)
        assert_includes output.text, "Hello Template!"
      end
    end
    
    it "have the correct default page size & layout settings - (default: A4 portrait)" do
      # NOTE! Dear North Americans, 
      # Please follow the ISO 216 international standard format (A4) that dominates everywhere else in the world
      template = Tilt::PrawnTemplate.new { |t| "pdf.text \"Hello A4 portrait!\"" }
      output   = _PdfOutput.new(template.render)
      assert_includes output.text, "Hello A4 portrait!"
      assert_equal [0, 0, 595.28, 841.89], output.page_attributes(1)[:MediaBox]
    end
    
    it "allows page size & layout settings - A3 landscape" do
      template = Tilt::PrawnTemplate.new( :page_size => 'A3', :page_layout => :landscape) { |t| "pdf.text \"Hello A3 landscape!\"" }
      output   = _PdfOutput.new(template.render)
      assert_includes output.text, "Hello A3 landscape!"
      assert_equal [0, 0, 1190.55, 841.89], output.page_attributes(1)[:MediaBox]
    end
    
  end
  
rescue LoadError
  warn "Tilt::PrawnTemplate (disabled)"
end
