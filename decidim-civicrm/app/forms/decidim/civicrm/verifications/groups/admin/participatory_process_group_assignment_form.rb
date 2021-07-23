# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        module Admin
          # This class holds a Form to create/update participatory process group assignments from Decidim's admin panel.
          class ParticipatoryProcessGroupAssignmentForm < Decidim::Form
            attribute :decidim_participatory_process_id, Integer
            attribute :civicrm_group_id, Integer

            validates :decidim_participatory_process_id, :civicrm_group_id, presence: true
          end
        end
      end
    end
  end
end
