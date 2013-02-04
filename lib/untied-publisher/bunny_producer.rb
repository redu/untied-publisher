require 'bunny'

module Untied
  module Publisher
    class BunnyProducer < Producer
      def initialize(opts={})
        super
        @conn = Bunny.new
        @conn.start
        @channel = @conn.create_channel
        @exchange = @channel.default_exchange
      end

      # Publish the given event.
      #   event: object which is going to be serialized and sent through the
      #   wire. It should respond to #to_json.
      def publish(event)
        if @opts[:deliver_messages]
          @exchange.publish(event.to_json, :routing_key => @routing_key)
          Publisher.config.logger.info \
            "Publishing event #{event.inspect} with routing key #{@routing_key}"
        else
          Publisher.config.logger.info \
            "The event #{event.inspect} was not delivered. Try to set " + \
            "Untied::Publisher.config.deliver_messages to true"

        end
      end
    end
  end
end
