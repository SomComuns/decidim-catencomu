# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        module Admin
          class GroupsController < Decidim::Admin::ApplicationController
            include NeedsPermission
            helper_method :workflows, :groups

            layout "decidim/admin/users"

            def index
              enforce_permission_to :index, :authorization
            end

            def update
              enforce_permission_to :create, :authorization

              if params[:id].present?
                Decidim::Civicrm::GroupVerificationJob.perform_later(params[:id])

                flash[:notice] = I18n.t("groups.update.success", group: params[:name], scope: "decidim.civicrm.verifications.groups.admin")
              else
                flash[:alert] = I18n.t("groups.update.error", group: params[:name], scope: "decidim.civicrm.verifications.groups.admin")
              end
              redirect_to root_path
            end

            def authorization_handler(authorization_handler)
              @authorization_handler = authorization_handler.presence || :groups
            end

            def current_authorization_handler
              authorization_handler(params[:authorization_handler])
            end

            def configured_workflows
              return Decidim::Civicrm.config.manage_workflows if Decidim::Civicrm.config

              ["groups"]
            end

            def workflows
              workflows = configured_workflows & current_organization.available_authorizations.map.to_a
              workflows.map do |a|
                [t("#{a}.name", scope: "decidim.authorization_handlers"), a]
              end
            end

            def groups
              @groups ||= Decidim::Civicrm::Api::Request.new.fetch_groups
            rescue StandardError
              flash.now[:alert] = I18n.t("groups.index.error", scope: "decidim.civicrm.verifications.groups.admin")
              @groups = []
            end
          end
        end
      end
    end
  end
end
