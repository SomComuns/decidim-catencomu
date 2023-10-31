# frozen_string_literal: true

module Decidim
  module CatcomuManagers
    class GroupConfig < ApplicationRecord
      self.table_name = "catcomu_managers_group_configs"

      belongs_to :participatory_process_group,
                 foreign_key: "decidim_participatory_process_group_id",
                 class_name: "Decidim::ParticipatoryProcessGroup",
                 optional: true
      belongs_to :civicrm_default_group,
                 class_name: "Decidim::Civicrm::Group",
                 optional: true
      belongs_to :civicrm_executive_group,
                 class_name: "Decidim::Civicrm::Group",
                 optional: true
    end
  end
end
