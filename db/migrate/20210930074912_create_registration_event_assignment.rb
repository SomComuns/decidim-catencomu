class CreateRegistrationEventAssignment < ActiveRecord::Migration[5.2]
  def change
    create_table :registration_event_assignments do |t|
      t.references :decidim_meetings_registration, null: false, index: {name: "decidim_meeting_registration_assignment"}
      t.integer :registration_id, null: false
      t.jsonb :data

      t.timestamps
    end

    add_index :registration_event_assignments, [:decidim_meetings_registration_id, :registration_id], unique: true, name: "registration_event_assignment_unique"
  end
end
