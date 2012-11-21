# -*- encoding : utf-8 -*-

module Untied
  class Event
    attr_accessor :name, :payload, :origin

    def initialize(attrs)
      @config = {
        :name => "after_create",
        :payload => nil,
        :origin => nil,
        :payload_representer => nil
      }.merge(attrs)

      raise "You should inform the origin service" unless @config[:origin]

      @name = @config.delete(:name)
      @payload = represent(@config.delete(:payload))
      @origin = @config.delete(:origin)

      self.extend(Publisher::EventRepresenter)
    end

    protected

    # Extends payload with representer and returns the hash. In cases there is
    # no representer, the raw payload is returned
    def represent(payload)
      if representer = @config[:payload_representer]
        payload.extend(representer)
        payload.to_hash
      else
        payload
      end
    end
  end
end
