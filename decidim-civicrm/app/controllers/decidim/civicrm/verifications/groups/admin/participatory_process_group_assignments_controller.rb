# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        module Admin
          class ParticipatoryProcessGroupAssignmentsController < Decidim::Admin::ApplicationController
            layout "decidim/admin/users"

            helper_method :assignments, :assignment, :groups

            def index; end

            def new
              @form = form(Decidim::Civicrm::Verifications::Groups::Admin::ParticipatoryProcessGroupAssignmentForm).instance
            end

            def create
              @form = form(Decidim::Civicrm::Verifications::Groups::Admin::ParticipatoryProcessGroupAssignmentForm).from_params(params)

              CreateParticipatoryProcessGroupAssignment.call(@form) do
                on(:ok) do
                  flash[:notice] = I18n.t("participatory_process_group_assignments.create.success", scope: "decidim.civicrm.verifications.groups.admin")
                  redirect_to participatory_process_group_assignments_path
                end

                on(:invalid) do
                  flash.now[:alert] = I18n.t("participatory_process_group_assignments.create.invalid", scope: "decidim.civicrm.verifications.groups.admin")
                  render action: "new"
                end
              end
            end

            def destroy
              DestroyParticipatoryProcessGroupAssignment.call(assignment, current_user) do
                on(:ok) do
                  flash[:notice] = I18n.t("participatory_process_group_assignments.destroy.success", scope: "decidim.civicrm.verifications.groups.admin")

                  redirect_to participatory_process_group_assignments_path
                end
              end
            end

            def update_participants
              Decidim::Civicrm::UpdateCivicrmGroupsJob.perform_later(current_organization.id)

              flash[:notice] = I18n.t("participatory_process_group_assignments.update_participants.success", scope: "decidim.civicrm.verifications.groups.admin")

              redirect_to participatory_process_group_assignments_path
            end

            private

            def assignments
              @assignments ||= Decidim::Civicrm::ParticipatoryProcessGroupAssignment.where(organization: current_organization)
            end

            def assignment
              @assignment ||= Decidim::Civicrm::ParticipatoryProcessGroupAssignment.find_by(id: params[:id])
            end

            def groups
              @groups ||= Decidim::Civicrm::Api::Request.new.fetch_groups
            rescue Decidim::Civicrm::Api::Error
              flash.now[:alert] = I18n.t("groups.index.error", scope: "decidim.civicrm.verifications.groups.admin")
              @groups = []
            end
          end
        end
      end
    end
  end
end
