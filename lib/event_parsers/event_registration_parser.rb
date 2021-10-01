# frozen_string_literal: true

module EventParsers
  class EventRegistrationParser < EventBaseParser
    def initialize(registration)
      @resource = registration
      @resource_type = :registration
      @resource_id = @resource.id
      @entity = "Participant"
      @action = "create"
      @model_class = RegistrationEventAssignment
    end

    def json
      {
        "event_id": event_id,
        "contact_id": contact_id
      }
    end

    def save!
      @model_class.create!({
                             registration_id: result["id"],
                             registration: @resource,
                             data: result
                           })
    end

    def valid?
      super
      @errors[:event_id] = "Event id is missing" if event_id.blank?
      @errors[:contact_id] = "Contact id is missing" if contact_id.blank?
      @errors.blank?
    end

    private

    def event_id
      @event_id ||= MeetingEventAssignment.find_by(meeting: @resource.meeting)&.event_id
    end

    def contact_id
      return @contact_id if @contact_id

      authorization = Decidim::Authorization.find_by(user: @resource.user, name: "civicrm")
      return unless authorization

      @contact_id = authorization.metadata["contact_id"]
    end
  end
end
