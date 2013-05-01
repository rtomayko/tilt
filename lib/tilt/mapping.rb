module Tilt
  class Mapping
    attr_reader :lazy_map, :template_map

    def initialize(options = {})
      @template_map = Hash.new
      @lazy_map = Hash.new { |h, k| h[k] = [] }
    end

    def register_lazy(class_name, file, *extensions)
      class_name = "Tilt::#{class_name}" if class_name.is_a?(Symbol)
      extensions.each do |ext|
        @lazy_map[ext].unshift([class_name, file])
      end
    end

    def register(template_class, *extensions)
      extensions.each do |ext|
        @template_map[ext] = template_class
      end
    end

    def registered?(ext)
      @template_map.has_key?(ext.downcase) or lazy?(ext)
    end

    def lazy?(ext)
      ext = ext.downcase
      @lazy_map.has_key?(ext) && !@lazy_map[ext].empty?
    end

    def new(file, line=nil, options={}, &block)
      if template_class = self[file]
        template_class.new(file, line, options, &block)
      else
        fail "No template engine registered for #{File.basename(file)}"
      end
    end

    def [](file)
      pattern = file.to_s.downcase
      until pattern.empty? || registered?(pattern)
        pattern = File.basename(pattern)
        pattern.sub!(/^[^.]*\.?/, '')
      end

      klass = @template_map[pattern]
      return klass if klass

      lazy_load(pattern)
    end

    def lazy_load(pattern)
      return unless @lazy_map.has_key?(pattern)
      first_failure = nil

      @lazy_map[pattern].each do |class_name, file|
        begin
          require file
          template_class = eval(class_name)
          @template_map[pattern] = template_class
          return template_class
        rescue LoadError => ex
          first_failure ||= ex
        end
      end

      raise first_failure if first_failure
    end
  end
end
