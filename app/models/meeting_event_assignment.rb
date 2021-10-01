# frozen_string_literal: true

class MeetingEventAssignment < ApplicationRecord
  belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
end
