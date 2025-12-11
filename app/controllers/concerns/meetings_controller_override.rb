# frozen_string_literal: true

module MeetingsControllerOverride
  extend ActiveSupport::Concern

  included do
    def default_filter_params
      {
        with_any_date: "all",
        title_or_description_cont: "",
        activity: "all",
        with_any_scope: nil,
        with_any_space: nil,
        with_any_type: nil,
        with_any_origin: nil,
        with_any_global_category: nil
      }
    end

    def meetings
      @meetings ||= paginate(search.result.order(start_time: :desc ))
    end
  end
end
