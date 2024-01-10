# frozen_string_literal: true

module Decidim
  module CatcomuManagers
    module Admin
      class CivicrmSyncForm < Decidim::Form
        mimic :config

        attribute :decidim_participatory_process_group_id, Integer
        attribute :civicrm_default_group_id, Integer
        attribute :civicrm_executive_group_id, Integer

        validates :decidim_participatory_process_group_id, :civicrm_default_group_id, :civicrm_executive_group_id, presence: true

        def participatory_process_group
          @participatory_process_group ||= Decidim::ParticipatoryProcessGroup.find(decidim_participatory_process_group_id)
        end

        def civicrm_default_group
          @civicrm_default_group ||= Decidim::Civicrm::Group.find(civicrm_default_group_id)
        end

        def civicrm_executive_group
          @civicrm_executive_group ||= Decidim::Civicrm::Group.find(civicrm_executive_group_id)
        end
      end
    end
  end
end
