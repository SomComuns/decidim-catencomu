# frozen_string_literal: true

module EventParsers
  class EventMeetingParser < EventBaseParser
    def initialize(meeting)
      @resource = meeting
      @resource_type = "Decidim::Meetings::Meeting"
      @resource_id = @resource.id
    end

    def data
      {
        start_date: @resource.start_time.strftime("%Y%m%d"),
        title: title,
        template_id: 2
      }
    end

    private

    def title
      meeting_title = @resource.title["ca"] || @resource.title["es"]
      space_title = @resource.participatory_space.title["ca"] || @resource.participatory_space.title["es"]
      "#{space_title}: #{meeting_title}"
    end
  end
end