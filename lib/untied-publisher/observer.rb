# -*- encoding : utf-8 -*-
require 'active_model'
require 'active_record/observer'
require 'active_record/callbacks'

module Untied
  module Publisher
    class Observer < ActiveRecord::Observer
      def initialize
        Publisher.config.logger.info "Untied: Initializing publisher observer"

        publisher.define_callbacks
        observed = publisher.observed_classes

        self.class.send(:define_method, :observed_classes, Proc.new { observed })
        super
      end

      def method_missing(name, model, *args, &block)
        if ActiveRecord::Callbacks::CALLBACKS.include?(name)
          options = args.first.is_a?(Hash) ? args.first : {}
          produce_event(name, model, options)
        else
          super
        end
      end

      protected

      def produce_event(callback, model, options={})
        if representer = options[:with_representer]
          model = model.extend(representer)
        end
        e = Event.new(:name => callback,
                      :payload => model, :origin => Publisher.config.service_name)
        e.extend(EventRepresenter)
        producer.publish(e)
      end

      def producer
        Producer.new
      end

      def publisher
        return @publisher if defined?(@publisher)

        unless Publisher.config.doorkeeper
          raise NameError.new "You should define a class which includes " + \
            "Untied::Publisher::Doorkeeper and set it name to Untied::Publisher.config.doorkeeper."
        end
        @publisher = Publisher.config.doorkeeper.new
      end
    end
  end
end
