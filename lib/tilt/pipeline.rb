require 'tilt'

module Tilt
  # @see Tilt::Mapping#pipeline
  def self.pipeline(ext, options={})
    default_mapping.pipeline(ext, options)
  end

  class Mapping
    # Register a new template class using the given extension that
    # represents a pipeline of multiple existing template, where the
    # output from the previous template is used as input to the next
    # template.  For example, if you just call this with a single
    # extension string:
    #
    #   mapping.pipeline('scss.erb')
    #
    # This will register a template class that processes the input
    # with the +erb+ template processor, and takes the output of
    # that and feeds it to the +scss+ template processor, returning
    # the output of the +scss+ template processor as the result of
    # the pipeline.
    #
    # Options:
    # :templates :: specify the templates to call in the given
    #               order, instead of determining them from the
    #               extension (e.g. <tt>['erb', 'scss']</tt>)
    # :extra_exts :: Any additional extensions you want to register
    #                for the created class (e.g. <tt>'scsserb'</tt>)
    # String :: Any string option that matches one of the templates
    #           being used in the pipeline is considered options
    #           for that template (e.g. <tt>'erb'=>{:outvar=>'@foo'},
    #           'scss'=>{:style=>:compressed}</tt>)
    def pipeline(ext, options={})
      templates = options[:templates] || ext.split('.').reverse
      templates = templates.map{|t| [self[t], options[t] || {}]}

      klass = Class.new(Pipeline)
      klass.send(:const_set, :TEMPLATES, templates)

      register(klass, ext, *Array(options[:extra_exts]))
      klass
    end
  end

  # Superclass used for pipeline templates.  Should not be used directly.
  class Pipeline < Template
    def prepare
      @pipeline = self.class::TEMPLATES.inject(proc{|*| data}) do |data, (klass, options)|
        proc do |s,l,&sb|
          klass.new(file, line, options, &proc{|*| data.call(s, l, &sb)}).render(s, l, &sb)
        end
      end
    end

    def evaluate(scope, locals, &block)
      @pipeline.call(scope, locals, &block)
    end
  end
end
