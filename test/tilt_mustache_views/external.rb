
begin
  require 'mustach'

  module Views
    class External < Mustache
      def hello
        "Stached"
      end
    end
  end

rescue LoadError => boom
  # silently fail, disabled message already displayed
end
