# Patch unmaintained Slim Template implementation to support sass-embedded.
# See mapping.rb for how it is loaded.
module Slim
  class Embedded
    # https://github.com/slim-template/slim/blob/v4.1.0/lib/slim/embedded.rb#L148-L161
    class SassEngine
      protected

      def tilt_render(tilt_engine, tilt_options, text)
        is_sass_embedded = tilt_engine <= ::Tilt::SassTemplate && tilt_engine::Engine.nil?
        text = tilt_engine.new(tilt_options.merge(
          style: options[:pretty] ? :expanded : :compressed
        ).merge!(
          is_sass_embedded ? { charset: false } : { cache: false }
        )) { text }.render
        text.chomp! unless text.frozen?
        [:static, text]
      end
    end
  end
end
