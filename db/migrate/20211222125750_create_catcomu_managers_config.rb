class CreateCatcomuManagersConfig < ActiveRecord::Migration[5.2]
  def change
    create_table :catcomu_managers_group_configs do |t|
      t.references :decidim_participatory_process_group, index: { name: "decidim_participatory_process_group_civicrm_managers_config" }
      t.references :civicrm_default_group, foreign_key: { to_table: :decidim_civicrm_groups }, index: { name: "decidim_civicrm_default_group_civicrm_managers_config" }
      t.references :civicrm_executive_group, foreign_key: { to_table: :decidim_civicrm_groups }, index: { name: "decidim_civicrm_executive_group_civicrm_managers_config" }
      t.jsonb :admins, default: []

      t.timestamps
    end
  end
end
