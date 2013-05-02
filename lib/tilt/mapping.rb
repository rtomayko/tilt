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
        template_class = constant_defined?(class_name)

        if !template_class
          begin
            require file

            if Thread.list.size > 1
              warn "WARN: tilt autoloading '#{file}' in a non thread-safe way; " +
                "explicit require '#{file}' suggested."
            end

            # It's safe to eval() here because constant_defined? will
            # raise NameError on invalid constant names
            template_class = eval(class_name)
          rescue LoadError => ex
            first_failure ||= ex
            next
          end
        end

        @template_map[pattern] = template_class
        return template_class
      end

      raise first_failure if first_failure
    end

    def constant_defined?(name)
      name.split('::').inject(Object) do |scope, n|
        return false unless scope.const_defined?(n)
        scope.const_get(n)
      end
    end
  end
end
