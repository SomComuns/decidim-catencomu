# frozen_string_literal: true

module Managers
  module Admin
    class ScopedAdminsController < Decidim::Admin::ApplicationController
      helper Managers::Admin::ApplicationHelper
      helper_method :processes_for_group, :process_form

      def index
      end

      def new_process
      end

      private

      def process_form(group)
        form(ProcessForm).from_params(group_id: group.id)
      end

      def processes_for_group(group)
        group.participatory_processes.each do |process|
          next if current_user.admin?

          fix_participatory_processes_membership(process)
        end
      end

      def fix_participatory_processes_membership(process)
        return if process.user_roles("admin")&.pluck(:decidim_user_id)&.include?(current_user.id)

        extra_info = {
          resource: {
            title: current_user.name
          }
        }
        role_params = {
          role: "admin",
          user: current_user,
          participatory_process: process
        }
        Decidim.traceability.create!(
          Decidim::ParticipatoryProcessUserRole,
          current_user,
          role_params,
          extra_info
        )
      end
    end
  end
end
