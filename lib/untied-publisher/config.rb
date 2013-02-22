# -*- encoding : utf-8 -*-
require 'configurable'
require 'logger'

module Untied
  module Publisher
    class Config
      include Configurable

      # Logger used by untied. Default: STDOUT
      config :logger, Logger.new(STDOUT)
      # Deliver the messages to AMQP broker. Default: true
      config :deliver_messages, true
      # An unique identifier to the publisher. Default: untied_publisher
      config :service_name, 'untied_publisher'
      # Doorkeeper class name. Default: DefaultDoorkeeper
      config :doorkeeper, Untied::Publisher::DefaultDoorkeeper
      # RabbitMQ adapter
      config :adapter, :Bunny
    end
  end
end

