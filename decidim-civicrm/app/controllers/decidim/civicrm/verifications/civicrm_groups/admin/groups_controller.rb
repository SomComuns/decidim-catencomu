# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module CivicrmGroups
        module Admin
          class GroupsController < Decidim::Admin::ApplicationController
            include NeedsPermission
            helper_method :workflows, :groups

            layout "decidim/admin/users"

            def index
              enforce_permission_to :index, :authorization
            end

            def authorization_handler(authorization_handler)
              @authorization_handler = authorization_handler.presence || :civicrm_groups
            end

            def current_authorization_handler
              authorization_handler(params[:authorization_handler])
            end

            def configured_workflows
              return Decidim::Civicrm.config.manage_workflows if Decidim::Civicrm.config

              ["civicrm_groups"]
            end

            def workflows
              workflows = configured_workflows & current_organization.available_authorizations.map.to_a
              workflows.map do |a|
                [t("#{a}.name", scope: "decidim.authorization_handlers"), a]
              end
            end

            def groups
              @groups ||= Decidim::Civicrm::Api::Request.new.fetch_groups
            end
          end
        end
      end
    end
  end
end
