# -*- encoding : utf-8 -*-

require 'representable/json'

module Untied
  module EventRepresenter
    include Representable::JSON

    self.representation_wrap = true

    property :name
    property :payload
    property :origin
  end
end
