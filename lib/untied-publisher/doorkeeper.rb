# -*- encoding : utf-8 -*-
module Untied
  module Publisher
    module Doorkeeper
      # The Doorkeeper defines which ActiveRecord models will be propagated to
      # other services. The instance method #watch is available for this.
      #
      # The Doorkeeper a similar way of ActiveRecord::Observer. It register
      # functions on the models which calls the method on Untied::Publisher::Observer
      # when ActiveRecord::Callbacks are fired.
      #
      # The following publisher watches the User after_create event:
      #
      #   class MyDoorkeeper
      #     include Untied::Publisher::Doorkeeper
      #
      #     def initialize
      #       watch User, :after_create
      #     end
      #   end

      # List of observed classes and callbacks
      def observed
        @observed ||= []
      end

      # Watches ActiveRecord lifecycle callbacks for some Class
      #
      #   class Doorkeeper
      #     include Untied::Publisher::Doorkeeper
      #   end
      #
      #   pub.new.watch(User, :after_create)
      #   User.create # sends the user into the wire
      def watch(*args)
        entity = args.shift
        options = args.last.is_a?(Hash) ? args.pop : {}
        observed << [entity, args, options]
      end

      # Returns the list of classes watched
      def observed_classes
        observed.collect(&:first).collect(&:to_s).uniq.collect(&:constantize)
      end

      # Defines the methods that are called when the registered callbacks fire.
      # For example, if the publisher is defined as follows:
      #
      #   class MyDoorkeeper
      #     include Untided::Publisher::Doorkeeper
      #
      #     def initialize
      #       watch User, :after_create
      #     end
      #   end
      #
      # After calling MyDoorkeeper#define_callbacks the method
      # _notify_untied__publisher_observer_for_after_create is created on User's
      # model. This method is called when the after_create callback is fired.
      def define_callbacks
        logger.debug "Untied::Publisher: defining callbacks"
        observed.each do |(klass, callbacks, options)|
          ActiveRecord::Callbacks::CALLBACKS.each do |callback|
            next unless callbacks.include?(callback)
            logger.debug "Untied::Publisher: seting up callback #{callback} for #{klass}"
            setup_observer(klass, callback, options)
          end
        end
      end

      protected

      def logger
        Publisher.config.logger
      end

      def setup_observer(klass, callback, options={})
        observer = Untied::Publisher::Observer
        observer_name = observer.name.underscore.gsub('/', '__')
        notifier_meth = :"_notify_#{observer_name}_for_#{callback}"

        if define_notifier_method(klass, observer, callback, notifier_meth, options)
          klass.send(callback, notifier_meth)
        end

        klass
      end

      def define_method_on(klass, method_name, &block)
        unless klass.respond_to?(method_name)
          klass.send(:define_method, method_name, &block)
        end
      end

      def define_notifier_method(klass, observer, callback, method_name, options={})
        define_method_on(klass, method_name) do
          observer.instance.send(callback, self, options)
        end
      end
    end
  end
end
