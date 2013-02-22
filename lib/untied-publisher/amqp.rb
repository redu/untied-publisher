require 'amqp/utilities/event_loop_helper'
require 'untied-publisher/amqp/producer'

module Untied
  module Publisher
    module AMQP
      def self.start
        config.channel ||= ::AMQP::Channel.new(::AMQP.connection)
      end

      def self.producer
        Untied::Publisher::AMQP::Producer
      end
    end
  end
end
