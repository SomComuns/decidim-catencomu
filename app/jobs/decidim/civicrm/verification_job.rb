# frozen_string_literal: true

module Decidim
  module Civicrm
    class VerificationJob < ApplicationJob
      queue_as :default

      def perform(user_id)
        handler = retrieve_handler(user_id)
        Decidim::Verifications::AuthorizeUser.call(handler) do
          on(:ok) do
            notify_user(handler.user, :ok, handler)
          end

          on(:invalid) do
            notify_user(handler.user, :invalid, handler)
          end
        end
      end

      private

      # Retrieves handler from Verification workflows registry.
      def retrieve_handler(user_id)
        byebug
        Decidim::AuthorizationHandler.handler_for('civicrm_handler', user: Decidim::User.find(user_id))
      end

      def notify_user(user, status, handler)
        byebug
        notification_class = status == :ok ? Decidim::Civicrm::VerificationSuccessNotification : Decidim::Civicrm::VerificationInvalidNotification
        Decidim::EventsManager.publish(
          event: "decidim.verifications.civicrm_handler.#{status}",
          event_class: notification_class,
          resource: user,
          extra: {
            status: status,
            errors: handler.errors.full_messages
          }
        )
      end
    end
  end
end
