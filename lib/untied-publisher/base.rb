module Untied
  module Publisher
    module Base
      def self.start
      end

      def self.producer
        Untied::Publisher::BaseProducer
      end
    end
  end
end
