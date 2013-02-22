# -*- encoding : utf-8 -*-
require 'amqp'

module Untied
  module Publisher
    # Generic class to provide message publishing.
    class BaseProducer
      attr_reader :routing_key, :service_name, :deliver_messages

      def initialize(opts={})
        extract_options!(opts)
      end

      # Publish the given event.
      #   event: object which is going to be serialized and sent through the
      #   wire. It should respond to #to_json.
      def publish(event)
        if deliver_messages
          safe_publish(event)
          say "Publishing event #{event.to_json} with routing key #{routing_key}"
        else
          say "The event #{event.to_json} was not delivered. Try to set " + \
              "Untied::Publisher.config.deliver_messages to true"
        end
      end

      private

      def extract_options!(opts)
        options = {
          :service_name => Publisher.config.service_name,
          :deliver_messages => Publisher.config.deliver_messages,
          :channel => nil,
        }.merge(opts)
        options[:routing_key] = "untied.#{options[:service_name]}"

        options.each do |k,v|
          instance_variable_set(:"@#{k}", v)
        end

        unless options[:service_name]
          msg = "you should inform service_name option or configure it " + \
                "through Untied::Publisher.configure block"
          raise ArgumentError.new(msg)
        end

        say "Producer intialized with options " + \
            "#{options.inspect} and routing key #{routing_key}"

        if !deliver_messages
          say "Channel was not setted up because message delivering is disabled."
        end
      end

      protected

      def say(msg)
        Publisher.config.logger.info "#{self.class.to_s}: #{msg}"
      end
    end
  end
end
