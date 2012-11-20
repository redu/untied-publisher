# -*- encoding : utf-8 -*-
require 'amqp'

module Untied
  module Publisher
    class Producer
      # Encapsulates both the Channel and Exchange (AMQP).

      def initialize(opts={})
        @opts = {
          :service_name => Publisher.config.service_name,
          :deliver_messages => Publisher.config.deliver_messages,
          :channel => nil,
        }.merge(opts)

        Publisher.config.logger.info "Untied::Publisher: Producer intialized with options #{@opts.inspect}"

        @routing_key = "untied.#{@opts[:service_name]}"

        if !@opts[:deliver_messages]
          Publisher.config.logger.info \
            "AMQP.channel was not setted up because message delivering is disabled."
          return
        end

        check_em_reactor

        if AMQP.channel || @opts[:channel]
          Publisher.config.logger.info "Using defined AMQP.channel"
          @channel = AMQP.channel || @opts[:channel]
        end
      end

      # Publish the given event.
      #   event: object which is going to be serialized and sent through the
      #   wire. It should respond to #to_json.
      def publish(event)
        safe_publish(event)
      end

      protected

      # Publishes if message delivering is enabled. Otherwise just warns.
      def safe_publish(e)
        if @opts[:deliver_messages]
          on_exchange do |exchange|
            exchange.publish(e.to_json, :routing_key => @routing_key) do
              Publisher.config.logger.info \
                "Publishing event #{e.inspect} with routing key #{@routing_key}"
            end
          end
        else
          Publisher.config.logger.info \
            "The event #{ e.inspect} was not delivered. Try to set " + \
            "Untied::Publisher.config.deliver_messages to true"
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
