# -*- encoding : utf-8 -*-
require 'amqp'

module Untied
  module Publisher
    class AMQPProducer < Producer
      # Encapsulates both the Channel and Exchange (AMQP).

      def initialize(opts={})
        super
        check_em_reactor
        if AMQP.channel || opts[:channel]
          say "Using defined AMQP.channel"
          @channel = AMQP.channel || opts[:channel]
        end
      end

      # Publish the given event.
      #   event: object which is going to be serialized and sent through the
      #   wire. It should respond to #to_json.
      def safe_publish(e)
        on_exchange do |exchange|
          exchange.publish(e.to_json, :routing_key => @routing_key)
        end
      end

      # Creates a new exchange and yields it to the block passed when it's ready
      def on_exchange(&block)
        return unless @channel
        @channel.topic('untied', :auto_delete => true, &block)
      end

      def check_em_reactor
        if !defined?(EventMachine) || !EM.reactor_running?
          raise "In order to use the producer you must be running inside an " + \
            "eventmachine loop"
        end
      end
    end
  end
end

