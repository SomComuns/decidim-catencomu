# frozen_string_literal: true

module EventParsers
  class EventRegistrationParser < EventBaseParser
    def initialize(registration)
      @resource = registration
      @resource_type = :registration
      @entity = "Participant"
      @action = "create"
    end

    def json
      {
        "event_id": nil,
        "contact_id": nil
      }
    end
  end
end
