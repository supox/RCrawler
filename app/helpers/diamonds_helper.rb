module DiamondsHelper
end


module Daemons
  module Rails
    class Controller
      def run(command)
        `#{path} #{command}`
      end
    end
  end
end
