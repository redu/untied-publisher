require 'bunny'

module Untied
  module Publisher
    module Bunny
      class Producer < BaseProducer
        def initialize(opts={})
          super

          begin
            connection.start
          rescue ::Bunny::TCPConnectionFailed => e
            say "Can't connect to RabbitMQ: #{e.message}"
          end
        end

        # Publish the given event.
        #   event: object which is going to be serialized and sent through the
        #   wire. It should respond to #to_json.
        def safe_publish(event)
          if connection.status == :open
            exchange.publish(event.to_json, :routing_key => routing_key)
          else
            say "Event not sent. Connection status is #{connection.status}: " + \
                "#{event.to_json}"
          end
        end

        protected

        def connection
          @connection ||= ::Bunny.new
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
end
