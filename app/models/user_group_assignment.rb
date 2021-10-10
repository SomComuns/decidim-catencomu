# frozen_string_literal: true

class UserGroupAssignment < ApplicationRecord
  self.table_name = "decidim_civicrm_user_group_assignments"

  belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"
end
