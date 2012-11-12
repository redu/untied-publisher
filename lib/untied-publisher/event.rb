# -*- encoding : utf-8 -*-

module Untied
  class Event
    extend Untied::EventRepresenter
    attr_accessor :name, :payload, :origin

    def initialize(attrs)
      @config = {
        :name => "after_create",
        :payload => nil,
        :origin => nil
      }.merge(attrs)

      raise "You should inform the origin service" unless @config[:origin]

      @name = @config.delete(:name)
      @payload = @config.delete(:payload)
      @origin = @config.delete(:origin)
    end
  end
end
