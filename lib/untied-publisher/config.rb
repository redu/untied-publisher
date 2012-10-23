# -*- encoding : utf-8 -*-
require 'configurable'
require 'logger'

module Untied
  module Publisher
    def self.configure(&block)
      yield(config) if block_given?
      if config.deliver_messages
        Untied::Publisher.start
        EventMachine.next_tick do
          config.channel ||= AMQP::Channel.new(AMQP.connection)
        end
      end
    end

    def self.config
      @config ||= Config.new
    end

    class Config
      include Configurable

      config :logger, Logger.new(STDOUT)
      config :deliver_messages, true
      config :service_name
      config :doorkeeper, nil
      config :channel, nil
    end
  end
end

