class CreateRegistrationEventAssignment < ActiveRecord::Migration[5.2]
  def change
    create_table :registration_event_assignments do |t|
      t.references :decidim_user, null: false, index: true
      t.references :decidim_meeting, null: false
      t.integer :registration_id, null: false, index: true
      t.jsonb :data

      t.timestamps
    end

    add_index :registration_event_assignments, [:decidim_user_id, :decidim_meeting_id, :registration_id], unique: true, name: "registration_event_assignment_unique"
  end
end
