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

        Publisher.config.logger.info \
          "Untied::Publisher: Producer intialized with options #{@opts.inspect}"

        @routing_key = "untied.#{@opts[:service_name]}"

        if !@opts[:deliver_messages]
          Publisher.config.logger.info \
            "Channel was not setted up because message delivering is disabled."
          return
        end
      end

      # Publish the given event.
      #   event: object which is going to be serialized and sent through the
      #   wire. It should respond to #to_json.
      def publish(event)
      end
    end
  end
end
