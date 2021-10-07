# frozen_string_literal: true

require "omniauth/civicrm"

module Decidim
  module Civicrm
    module Verifications
      module Groups
        # This is an engine that implements the interface for
        # user authorization by civicrm group.
        class Engine < ::Rails::Engine
          isolate_namespace Decidim::Civicrm::Verifications::Groups

          paths["lib/tasks"] = nil

          routes do
            resource :authorizations, only: [:new, :create, :edit], as: :authorization

            root to: "authorizations#new"
          end

          config.to_prepare do
            # omniauth only trigger notifications when a new user is registered
            # this adds a notification too when user logs in
            Decidim::CreateOmniauthRegistration.include(Decidim::CreateOmniauthRegistrationOverride)
          end

          initializer "decidim_civicrm.omniauth" do
            next unless Decidim::Civicrm.omniauth && Decidim::Civicrm.omniauth[:client_id]

            Rails.application.config.middleware.use OmniAuth::Builder do
              provider :civicrm,
              client_id: Decidim::Civicrm.omniauth[:client_id],
              client_secret: Decidim::Civicrm.omniauth[:client_secret],
              site: Decidim::Civicrm.omniauth[:site],
              scope: "openid profile email"
            end
          end

          initializer "decidim_civicrm.user_contact_id" do
            # Trigger extra data information fetcher for the user
            ActiveSupport::Notifications.subscribe "decidim.user.omniauth_registration" do |_name, data|
              Decidim::Civicrm::OmniauthAutoVerificationJob.perform_now(data)
            end
          end

          initializer "decidim_civicrm.authorizations" do
            next unless Decidim::Civicrm.authorizations

            if Decidim::Civicrm.authorizations.include?(:civicrm)
              # Generic verification method using civicrm contacts
              # A omniauth operation will try to use this method to obtain the contact_id and store it
              # as an extended_data attribute of the user
              Decidim::Verifications.register_workflow(:civicrm) do |workflow|
                workflow.form = "Decidim::Civicrm::Verifications::Civicrm"

                workflow.options do |options|
                  options.attribute :role, type: :enum, choices: -> { Decidim::Civicrm::Api::User::ROLES.values.map(&:to_s) }
                  options.attribute :regional_scope, type: :enum, choices: -> { Decidim::Civicrm::Api::RegionalScope::ALL.keys.map(&:to_s) }
                end
              end
            end

            if Decidim::Civicrm.authorizations.include?(:groups)
              # # Another automated verification method that stores all the groups obtained from civicrm
              Decidim::Verifications.register_workflow(:groups) do |workflow|
                workflow.form = "Decidim::Civicrm::Verifications::CivicrmGroups"
                # workflow.engine = Decidim::Civicrm::Verifications::Groups::Engine
                # workflow.admin_engine = Decidim::Civicrm::Verifications::Groups::AdminEngine
                # workflow.action_authorizer = "Decidim::Civicrm::Verifications::Groups::GroupsActionAuthorizer"

                workflow.options do |options|
                  # options.attribute :group, type: :enum, choices: -> { Decidim::Civicrm::Api::Request.new.fetch_groups.map { |g| g[:name].downcase.to_sym } }
                  options.attribute :groups, type: :array
                end
              end
            end
          end
        end
      end
    end
  end
end
