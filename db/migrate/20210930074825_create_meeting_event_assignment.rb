class CreateMeetingEventAssignment < ActiveRecord::Migration[5.2]
  def change
    create_table :meeting_event_assignments do |t|
      t.references :decidim_meeting, null: false, index: true
      t.integer :event_id, null: false
      t.jsonb :data

      t.timestamps
    end

    add_index :meeting_event_assignments, [:decidim_meeting_id, :event_id], unique: true, name: "meetings_event_assignment_unique"
  end
end
