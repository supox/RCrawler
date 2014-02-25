module DiamondsHelper
end

class Numeric
  def to_size_range
    "#{"%.2f" % self}-#{(self+0.09).round(2)}"
  end
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
