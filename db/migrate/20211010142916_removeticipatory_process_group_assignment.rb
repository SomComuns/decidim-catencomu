# frozen_string_literal: true

class RemoveticipatoryProcessGroupAssignment < ActiveRecord::Migration[5.2]
  def change
    drop_table :decidim_civicrm_participatory_process_group_assignments, if_exists: true
    drop_table :decidim_civicrm_user_group_assignments, if_exists: true
  end
end
