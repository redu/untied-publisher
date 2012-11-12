require "untied-publisher/version"

require 'rubygems'
require 'bundler/setup'
require 'amqp/utilities/event_loop_helper'

module Untied
  module Publisher
    def self.start
      Thread.abort_on_exception = false

      AMQP::Utilities::EventLoopHelper.run do
        AMQP.start
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
