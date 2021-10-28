class CopyCivicrmEventAssignments < ActiveRecord::Migration[5.2]
  def up
    MeetingEventAssignment.find_each do |assignment|
      event_meeting = Decidim::Civicrm::EventMeeting.find_or_initialize_by(
        meeting: assignment.meeting,
        civicrm_event_id: assignment.event_id
      )
      event_meeting.organization = assignment.meeting.organization
      event_meeting.data = assignment.data
      event_meeting.created_at = assignment.created_at
      event_meeting.updated_at = assignment.updated_at
      event_meeting.save!
    end

    RegistrationEventAssignment.find_each do |assignment|
      event_registration = Decidim::Civicrm::EventRegistration.find_or_initialize_by(
        meeting_registration: assignment.registration,
        civicrm_event_registration_id: assignment.registration_id
      )
      next unless assignment.registration
      event_registration.event_meeting = Decidim::Civicrm::EventMeeting.find_by(meeting: assignment.registration.meeting)
      event_registration.data = assignment.data
      event_registration.created_at = assignment.created_at
      event_registration.updated_at = assignment.updated_at
      event_registration.save!
    end
  end
end
