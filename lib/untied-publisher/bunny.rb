require 'untied-publisher/bunny/producer'

module Untied
  module Publisher
    module Bunny
      def self.start
        # Nothing to do here
      end

      def self.producer
        Untied::Publisher::Bunny::Producer
      end
    end
  end
end
