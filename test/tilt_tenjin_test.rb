# coding: utf-8
require 'contest'
require 'tilt'
require 'tenjin'
require 'tempfile'

class TenjinTemplateTest < Test::Unit::TestCase

  test "should support a simple template" do
  
    tpl = Tilt::TenjinTemplate.new(){
      'foo #{bar} ${baz}'
    }
  
    assert_equal tpl.render(Object.new, 'bar'=>'BAR','baz'=>'BAZ'), 'foo BAR BAZ'
    
  end
  
  test "should support yield" do
  
    tpl = Tilt::TenjinTemplate.new(){
      'foo #{yield} baz'
    }
  
    result = tpl.render do
    
      "BAR"
    
    end
  
    assert_equal result , 'foo BAR baz'
  
  end
  
  test "should have correct line-numbers" do
  
    tpl = Tilt::TenjinTemplate.new('a_template'){
<<'TENJIN'
line one
line two
${raise "Line THREE!"}
line four
TENJIN
    }
    
    error = nil
    begin
      tpl.render
    rescue
      error = $!
    end
    assert_not_nil error
    assert error.backtrace.first =~ /\Aa_template:3/, "First backtrace should contain the template name and line number, but got: #{error.backtrace.first.inspect}"
  
  end
  
  test "should accept custom helpers" do
  
    module Foo
       def foo
         "BAR!"
       end
    end
    
    Tilt[:tenjin].engine.use(Foo)
    
    tpl = Tilt.new('tpl.tenjin'){ 'Hello #{foo}'}
    assert_equal tpl.render, "Hello BAR!"
    
  end

end
