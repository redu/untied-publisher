# -*- encoding : utf-8 -*-

require 'representable/json'

module Untied
  module Publisher
    module EventRepresenter
      # Publisher::Event is extended with this module at runtime. It defines
      # how the event will be serialized.

      include Representable::JSON
      self.representation_wrap = true

      property :name
      property :payload
      property :origin
    end
  end
end
