# frozen_string_literal: true

module Decidim
  module Civicrm
    class GroupVerificationJob < ApplicationJob
      queue_as :default

      def perform(group_id)
        civicrm_users = Decidim::Civicrm::Api::Request.new.users_in_group(group_id)
        uids = civicrm_users.map { |user| user.dig("api.User.get", "values", 0, "id") }
        user_ids = Decidim::Identity.where(uid: uids).pluck(:decidim_user_id)

        Decidim::User.where(id: user_ids).find_each do |user|
          handler = retrieve_handler(user) # TODO

          Decidim::Verifications::AuthorizeUser.call(handler) do
            on(:ok) do
              notify_user(user, :ok, handler)
            end

            on(:invalid) do
              notify_user(user, :invalid, handler)
            end
          end
        end
      end

      private

      # Retrieves handler from Verification workflows registry.
      def retrieve_handler(user)
        Decidim::AuthorizationHandler.handler_for("groups", user: user)
      end

      def notify_user(user, status, handler)
        notification_class = status == :ok ? Decidim::Civicrm::VerificationSuccessNotification : Decidim::Civicrm::VerificationInvalidNotification
        Decidim::EventsManager.publish(
          event: "decidim.events.civicrm_verification.#{status}",
          event_class: notification_class,
          resource: user,
          affected_users: [user],
          extra: {
            status: status.to_s,
            errors: handler.errors.full_messages
          }
        )
      end
    end
  end
end
