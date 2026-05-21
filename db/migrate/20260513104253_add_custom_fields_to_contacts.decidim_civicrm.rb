# frozen_string_literal: true

# This migration comes from decidim_civicrm (originally 20260211120000)
class AddCustomFieldsToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_civicrm_contacts, :custom_fields, :jsonb, default: {}, null: false
    add_column :decidim_civicrm_group_memberships, :custom_fields, :jsonb, default: {}, null: false
  end
end
