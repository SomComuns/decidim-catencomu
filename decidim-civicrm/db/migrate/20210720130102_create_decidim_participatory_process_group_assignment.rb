# frozen_string_literal: true

class CreateDecidimParticipatoryProcessGroupAssignment < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_civicrm_participatory_process_group_assignments do |t|
      t.references :decidim_organization, null: false, foreign_key: true, index: { name: "participatory_process_group_assignment_organization" }
      t.references :decidim_participatory_process, null: false, foreign_key: true, index: { name: "participatory_process_group_assignment_process" }
      t.integer :civicrm_group_id, null: false, foreign_key: true, index: { name: "participatory_process_group_assignment_group" }

      t.timestamps
    end
  end
end
