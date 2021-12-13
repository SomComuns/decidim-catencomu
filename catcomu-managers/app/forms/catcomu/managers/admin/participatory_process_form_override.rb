# frozen_string_literal: true

module Catcomu
  module Managers
    module Admin
      module ParticipatoryProcessFormOverride
        extend ActiveSupport::Concern
        include Managers::Admin::ApplicationHelper

        included do
          validate :allowed_process_group

          def allowed_process_group
            return if current_user.attributes["admin"].present?

            return if current_user_process_groups&.pluck(:id)&.include?(participatory_process_group_id)

            errors.add(:participatory_process_group_id, :user_not_admin_in_group)
          end
        end
      end
    end
  end
end
