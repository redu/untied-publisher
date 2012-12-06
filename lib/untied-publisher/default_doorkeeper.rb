module Untied
  module Publisher
    # Default Doorkeeper. Don't let anyone pass.
    class DefaultDoorkeeper
      include Doorkeeper
    end
  end
end
