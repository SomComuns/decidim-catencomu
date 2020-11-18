# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module CivicrmGroups
        class GroupVerificationJob < ApplicationJob
          queue_as :default

          def perform(group_id)
            civicrm_users = Decidim::Civicrm::Api::Request.new.users_in_group(group_id)
            uids = civicrm_users.map { |user| user["user_id"] }
            users = Decidim::User.joins(:identity).where(decidim_identities: { uid: uids })

            users.find_each do |user|
              handler = retrieve_handler(user)

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
            Decidim::AuthorizationHandler.handler_for("civicrm_groups", user: user)
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
  end
end
