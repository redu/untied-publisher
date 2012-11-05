# -*- encoding : utf-8 -*-

require 'representable/json'

module Untied
  class Event
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

  module EventRepresenter
    include Representable::JSON

    self.representation_wrap = true

    property :name
    property :payload
    property :origin
  end
end
