# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        module Admin
          class GroupsController < Decidim::Admin::ApplicationController
            include NeedsPermission
            helper_method :groups

            layout "decidim/admin/users"

            def index
              enforce_permission_to :index, :authorization
            end

            def update
              enforce_permission_to :create, :authorization

              if params[:id].present?
                Decidim::Civicrm::GroupVerificationJob.perform_later(params[:id], params[:name], current_organization.id)

                flash[:notice] = I18n.t("groups.update.success", group: params[:title], scope: "decidim.civicrm.verifications.groups.admin")
              else
                flash[:alert] = I18n.t("groups.update.error", group: params[:title], scope: "decidim.civicrm.verifications.groups.admin")
              end
              redirect_to root_path
            end

            def groups
              @groups ||= Decidim::Civicrm::Api::Request.new.fetch_groups
              update_group_verification_options

              @groups
            rescue Decidim::Civicrm::Api::Error
              flash.now[:alert] = I18n.t("groups.index.error", scope: "decidim.civicrm.verifications.groups.admin")
              @groups = []
            end

            def update_group_verification_options
              fields_translations = {}

              @groups.each do |group|
                key = Decidim::Civicrm::Api::Group.name_to_key(group[:name])
                fields_translations[key] = group[:title]
              end

              I18n.available_locales.each do |locale|
                I18n.backend.store_translations(
                  locale, decidim: { authorization_handlers: { groups: { fields: { group_choices: fields_translations } } } }
                )
              end
            end
          end
        end
      end
    end
  end
end
