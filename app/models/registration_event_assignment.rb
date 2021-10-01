# frozen_string_literal: true

class RegistrationEventAssignment < ApplicationRecord
  belongs_to :registration, foreign_key: "decidim_meetings_registration_id", class_name: "Decidim::Meetings::Registration"

  delegate :user, to: :registration
  delegate :user_group, to: :registration
  delegate :meeting, to: :registration
end
