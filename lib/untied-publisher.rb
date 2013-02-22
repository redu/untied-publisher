require "untied-publisher/version"

require 'rubygems'
require 'bundler/setup'

require 'untied-publisher/event_representer'
require 'untied-publisher/event'
require 'untied-publisher/doorkeeper'
require 'untied-publisher/default_doorkeeper'
require 'untied-publisher/config'
require 'untied-publisher/observer'
require 'untied-publisher/base_producer'
require 'untied-publisher/amqp'
require 'untied-publisher/bunny'
require 'untied-publisher/base'

module Untied
  module Publisher
    # Configures untied-publisher.
    def self.configure(&block)
      yield(config) if block_given?
      if config.deliver_messages
        adapter.start
      else
        config.adapter = :Base
        adapter.start
      end
    end

    def self.config
      @config ||= Config.new
    end

    def self.adapter
      producer_booter = "Untied::Publisher::#{self.config.adapter}"

      @adapter ||= begin
        begin
          constantize(producer_booter)
        rescue NameError
          config.logger.info "#{producer_booter} is not defined. Falling back " +\
            "to Untied::Publisher::Bunny"
          Untied::Publisher::Bunny
        end
     end
    end

    # Transforms string into constant
    def self.constantize(class_name)
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ class_name
        raise NameError, "#{class_name.inspect} is not a valid constant name!"
      end

      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end
  end
end

require 'untied-publisher/railtie' if defined?(Rails)
