# frozen_string_literal: true

module EventParsers
  class EventRegistrationParser < EventBaseParser
    def initialize(registration)
      @resource = registration
      @resource_type = :registration
    end

    def data
      {
        "event_id": nil,
        "contact_id": nil
      }
    end
  end
end