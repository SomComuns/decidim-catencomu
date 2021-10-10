# frozen_string_literal: true

module EventParsers
  class EventMeetingParser < EventBaseParser
    def initialize(meeting)
      @resource = meeting
      @resource_type = "Decidim::Meetings::Meeting"
      @resource_id = @resource.id
      @entity = "Event"
      @action = "create"
      @model_class = MeetingEventAssignment
    end

    def json
      {
        start_date: @resource.start_time.strftime("%Y%m%d"),
        end_date: @resource.start_time.strftime("%Y%m%d"),
        title: title,
        template_id: 2
      }
    end

    def save!
      @model_class.create!({
                             event_id: result["id"],
                             meeting: @resource,
                             data: result
                           })
    end

    private

    def title
      meeting_title = @resource.title["ca"] || @resource.title["es"] || @resource.title["en"]
      space_title = @resource.participatory_space.title["ca"] || @resource.participatory_space.title["es"] || @resource.title["en"]
      "#{space_title}: #{meeting_title}"
    end
  end
end
