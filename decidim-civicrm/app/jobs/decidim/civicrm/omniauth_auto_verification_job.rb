# frozen_string_literal: true

module Decidim
  module Civicrm
    class OmniauthAutoVerificationJob < ApplicationJob
      queue_as :default

      def perform(data)
        @user = Decidim::User.find(data[:user_id])
        info = data[:raw_data] && data[:raw_data][:info]
        if info
          @user.extended_data = {
            contact_id: info[:contact_id],
            role: info[:role],
            regional_scope: info[:regional_scope]
          }
          @user.save
        end

        if civicrm_user?
          perform_civicrm_auth 
          perform_groups_auth
        end
      end

      def perform_civicrm_auth
        handler = Decidim::AuthorizationHandler.handler_for("civicrm", user: @user)
        Decidim::Verifications::AuthorizeUser.call(handler) do
          on(:ok) do
            Rails.logger.info "Success: Civicrm Authorization for user #{handler.user.id} as contact_id: #{handler.user.extended_data["contact_id"]}"
          end

          on(:invalid) do
            Rails.logger.error "Error: Civicrm Authorization for user #{handler&.user&.id}"
          end
        end
      end

      def perform_groups_auth
        handler = Decidim::AuthorizationHandler.handler_for("groups", user: @user)
        return unless handler

        Decidim::Verifications::AuthorizeUser.call(handler) do
          on(:ok) do
            Rails.logger.info "Success: Civicrm Groups Authorization for user #{handler.user.id} as contact_id: #{handler.user.extended_data["contact_id"]}"
          end

          on(:invalid) do
            Rails.logger.error "Error: Civicrm Groups Authorization for user #{handler&.user&.id}"
          end
        end
      end

      private
      
      def civicrm_user?
        @user.identities.find_by(provider: Decidim::Civicrm::Verifications::Civicrm::PROVIDER_NAME).present?
      end
    end
  end
end
