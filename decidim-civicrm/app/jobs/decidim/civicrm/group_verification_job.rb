# frozen_string_literal: true

module Decidim
  module Civicrm
    class GroupVerificationJob < ApplicationJob
      queue_as :default

      def perform(group_id, group_name)
        civicrm_users = Decidim::Civicrm::Api::Request.new.users_in_group(group_id)
        uids = civicrm_users.map { |user| user.dig("api.User.get", "values", 0, "id") }
        user_ids = Decidim::Identity.where(uid: uids).pluck(:decidim_user_id)

        Decidim::User.where(id: user_ids).find_each do |user|
          authorization = Decidim::Authorization.find_by(user: user, name: "groups")
          if authorization.blank?
            authorization = Decidim::Authorization.create!(
              user: user,
              name: "groups",
              metadata: {},
              unique_id: Digest::SHA512.hexdigest(
                "#{user.id}-groups-#{Rails.application.secrets.secret_key_base}"
              )
            )
          end

          metadata = authorization.metadata.merge(group_name => true)

          authorization.update!(metadata: metadata)

          notify_user(user) if authorization.grant!
        end
      end

      private

      def notify_user(user)
        Decidim::EventsManager.publish(
          event: "decidim.events.civicrm_verification.ok",
          event_class: Decidim::Civicrm::VerificationSuccessNotification,
          resource: user,
          affected_users: [user],
          extra: {
            status: "ok"
          }
        )
      end
    end
  end
end
