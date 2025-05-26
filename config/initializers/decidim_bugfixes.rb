# frozen_string_literal: true

# NOTE: remove this when fix merged

Rails.application.config.to_prepare do
  Decidim::ParticipatoryProcesses::ParticipatoryProcessesController.class_eval do
    private

    def search_collection
      published_processes.query.includes(:area)
    end
  end

  Decidim::Debates::DebateCardMetadataCell.class_eval do
    def debate_items
      [label, duration, comments_count_item, endorsements_count_item, category_item, coauthors_item]
    end

    def label
      {
        text: content_tag("span", t((debate.closed? ? "debate_closed" : "open"), scope: "decidim.debates.debates.show"), class: "#{debate.closed? ? "alert" : "success"} label")
      }
    end

    def duration
      text = format_date_range(debate.start_time, debate.end_time)
      return if text.blank?

      {
        text:,
        icon: "time-line"
      }
    end
  end
end
