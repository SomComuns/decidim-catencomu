# frozen_string_literal: true

module Decidim
  module Civicrm
    class ParticipatoryProcessGroupAssignment < ApplicationRecord
      self.table_name = "decidim_civicrm_participatory_process_group_assignments"

      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: "decidim_organization_id"
      belongs_to :participatory_process, class_name: "Decidim::ParticipatoryProcess", foreign_key: "decidim_participatory_process_id"
    end
  end
end
