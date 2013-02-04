require "untied-publisher/version"

require 'rubygems'
require 'bundler/setup'
require 'amqp/utilities/event_loop_helper'

module Untied
  module Publisher
    def self.start
      Thread.abort_on_exception = false

      self.run do
        AMQP.start
      end
    end

    def self.run(&block)
      @block = block
      if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          EM.stop if forked && EM.reactor_running?
          Thread.new { EM.run { @block.call } }
        end
      else
        AMQP::Utilities::EventLoopHelper.run { @block.call }
      end
    end

    # Configures untied-publisher. The options are defined at
    # lib/untied-publisher/config.rb
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
  end
end

require 'untied-publisher/event_representer'
require 'untied-publisher/event'
require 'untied-publisher/doorkeeper'
require 'untied-publisher/default_doorkeeper'
require 'untied-publisher/config'
require 'untied-publisher/observer'
require 'untied-publisher/producer'
require 'untied-publisher/amqp_producer'
require 'untied-publisher/bunny_producer'
require 'untied-publisher/railtie' if defined?(Rails)
