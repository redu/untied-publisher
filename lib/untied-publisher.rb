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
  end
end


require 'untied-publisher/event_representer'
require 'untied-publisher/event'
require 'untied-publisher/config'
require 'untied-publisher/doorkeeper'
require 'untied-publisher/observer'
require 'untied-publisher/producer'
require 'untied-publisher/railtie' if defined?(Rails)
