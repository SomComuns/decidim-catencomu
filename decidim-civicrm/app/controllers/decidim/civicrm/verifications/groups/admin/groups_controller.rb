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
                Decidim::Civicrm::GroupVerificationJob.perform_later(params[:id], params[:name])

                flash[:notice] = I18n.t("groups.update.success", group: params[:name], scope: "decidim.civicrm.verifications.groups.admin")
              else
                flash[:alert] = I18n.t("groups.update.error", group: params[:name], scope: "decidim.civicrm.verifications.groups.admin")
              end
              redirect_to root_path
            end

            def workflows
              workflows = configured_workflows & current_organization.available_authorizations.map.to_a
              workflows.map do |a|
                [t("#{a}.name", scope: "decidim.authorization_handlers"), a]
              end
            end

            def groups
              if @groups.blank?
                @groups = Decidim::Civicrm::Api::Request.new.fetch_groups
                update_group_verification_options
              end

              @groups
            rescue Decidim::Civicrm::Api::Error
              flash.now[:alert] = I18n.t("groups.index.error", scope: "decidim.civicrm.verifications.groups.admin")
              @groups = []
            end

            def update_group_verification_options
              fields_translations = {}

              workflow = Decidim::Verifications.find_workflow_manifest("groups")
              workflow.options do |options|
                groups.each do |group|
                  fields_translations[group[:name]] = group[:title]
                  options.attribute group[:name].to_sym, type: :boolean, default: false
                end
              end

              I18n.available_locales.each do |locale|
                I18n.backend.store_translations(
                  locale, decidim: { authorization_handlers: { groups: { fields: fields_translations } } }
                )
              end
            end
          end
        end
      end
    end
  end
end
