require 'bunny'

module Untied
  module Publisher
    class BunnyProducer < Producer
      def initialize(opts={})
        super

        connection.start
      end

      # Publish the given event.
      #   event: object which is going to be serialized and sent through the
      #   wire. It should respond to #to_json.
      def safe_publish(event)
        exchange.publish(event.to_json, :routing_key => routing_key)
      end

      protected

      def connection
        @connection ||= Bunny.new
      end

      def exchange
        @exchange ||= channel.topic('untied', :auto_delete => true)
      end

      def channel
        @channel ||= connection.create_channel
      end
    end
  end
end
