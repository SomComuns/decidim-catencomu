# frozen_string_literal: true

module MeetingsControllerOverride
  extend ActiveSupport::Concern

  included do
    def default_filter_params
      {
        with_any_date: "all",
        title_or_description_cont: "",
        activity: "all",
        with_any_taxonomies: nil,
        with_any_space: nil,
        with_any_type: nil,
        with_any_origin: nil
      }
    end

    def meetings
      is_upcoming_meetings = params.dig("filter", "with_any_date")&.include?("upcoming")
      @meetings ||= paginate(search.result.order(start_time: is_upcoming_meetings ? :asc : :desc))
    end
  end
end
