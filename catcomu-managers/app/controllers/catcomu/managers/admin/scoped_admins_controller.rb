# frozen_string_literal: true

module Catcomu
  module Managers
    module Admin
      class ScopedAdminsController < Decidim::Admin::ApplicationController
        include Managers::Admin::ApplicationHelper
        helper Managers::Admin::ApplicationHelper
        helper_method :processes_for_group, :process_form

        def index; end

        def new_process
          return if current_user_process_groups.blank?

          @form = process_form
          return unless current_user_process_groups.pluck(:id).include?(@form.participatory_process_group_id)

          Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.call(@form) do
            on(:ok) do |_participatory_process|
              flash[:notice] = I18n.t("participatory_processes.create.success", scope: "decidim.admin")
              redirect_to scoped_admins_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_processes.create.error", scope: "decidim.admin")
              render :index
            end
          end
        end

        private

        def process_form(group = nil)
          attrs = params
          attrs.merge!({ participatory_process_group_id: group.id }) if group
          attrs.merge!({ scopes_enabled: false })
          form(Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm).from_params(attrs)
        end

        def processes_for_group(group)
          group.participatory_processes.each do |process|
            next if current_user.admin?

            fix_participatory_processes_membership(process)
          end
        end

        def fix_participatory_processes_membership(process)
          return if user_process_admin?(current_user, process)

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
end
