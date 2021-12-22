# frozen_string_literal: true

module Catcomu
  module Managers
    module Admin
      class ScopedAdminsController < Decidim::Admin::ApplicationController
        include Managers::Admin::ApplicationHelper
        helper Managers::Admin::ApplicationHelper
        helper_method :processes_for_group, :process_form, :civicrm_groups_for_process, :civicrm_groups_for_group, :superadmin?, :civicrm_groups_list, :sync_form
        # this module is accessible to non-admin users (as processes Awesome scoped_admins)
        # in order to draw the Decidim standard menu, we need to manually set the current user as (pseudo)admin when accessing this controller
        before_action do
          Decidim::User.awesome_admins_for_current_scope = [current_user.id] if current_user
        end

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

        def set_sync_groups
          @sync_form = form(CivicrmSyncForm).from_params(params)
          if superadmin?
            config = Catcomu::Managers::GroupConfig.find_or_initialize_by(participatory_process_group: @sync_form.participatory_process_group)
            config.civicrm_default_group = @sync_form.civicrm_default_group
            config.civicrm_executive_group = @sync_form.civicrm_executive_group
            config.save!
          else
            flash[:alert] = I18n.t("index.superadmin_only", scope: "catcomu.managers.admin.scoped_admins")
          end
          redirect_to "#{scoped_admins_path}#sync-form-#{@sync_form.decidim_participatory_process_group_id}"
        end

        private

        def process_form(group = nil)
          attrs = params
          attrs.merge!({ participatory_process_group_id: group.id }) if group
          attrs.merge!({ scopes_enabled: false, private_space: true })
          form(Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm).from_params(attrs)
        end

        def sync_form(group = nil)
          attrs = params
          if group
            attrs.merge!({ decidim_participatory_process_group_id: group.id })
            config = Catcomu::Managers::GroupConfig.find_by(participatory_process_group: group)
            attrs.merge!({ civicrm_default_group_id: config.civicrm_default_group_id, civicrm_executive_group_id: config.civicrm_executive_group_id }) if config
          end
          form(CivicrmSyncForm).from_params(attrs)
        end

        def processes_for_group(group)
          group.participatory_processes.each do |process|
            next if superadmin?

            fix_participatory_processes_membership(process)
          end
        end

        def civicrm_groups_list
          @civicrm_groups_list ||= Decidim::Civicrm::Group.where(organization: current_organization).order(title: :asc).map do |group|
            [group.title, group.id]
          end
        end

        def civicrm_groups_for_process(processes)
          Decidim::Civicrm::GroupParticipatorySpace.where(participatory_space: processes)
        end

        def civicrm_groups_for_group(group)
          all_processes = Decidim::ParticipatoryProcess.where(participatory_process_group: group)
          civicrm_groups_for_process(all_processes)
        end

        def superadmin?
          current_user.attributes["admin"]
        end

        def fix_participatory_processes_membership(process)
          # Add it as a normal private participant if not already
          Decidim::ParticipatorySpacePrivateUser.find_or_create_by(decidim_user_id: current_user.id, privatable_to: process)

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
