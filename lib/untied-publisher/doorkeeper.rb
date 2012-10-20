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
      #     include Untied::Doorkeeper
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
      #     include Untied::Doorkeeper
      #   end
      #
      #   pub.new.watch(User, :after_create)
      #   User.create # sends the user into the wire
      def watch(*args)
        entity = args.shift
        observed << [entity, args]
      end

      # Returns the list of classes watched
      def observed_classes
        observed.collect(&:first).collect(&:to_s).uniq.collect(&:constantize)
      end

      # Defines the methods that are called when the registered callbacks fire.
      # For example, if the publisher is defined as follows:
      #
      #   class MyDoorkeeper
      #     include Untided::Doorkeeper
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
        observer = Untied::Publisher::Observer
        observer_name = observer.name.underscore.gsub('/', '__')

        observed.each do |(klass, callbacks)|
          ActiveRecord::Callbacks::CALLBACKS.each do |callback|
          next unless callbacks.include?(callback)
          callback_meth = :"_notify_#{observer_name}_for_#{callback}"
          unless klass.respond_to?(callback_meth)
            klass.send(:define_method, callback_meth) do
              observer.instance.send(callback, self)
            end
            klass.send(callback, callback_meth)
          end
        end
        end
      end
    end
  end
end
