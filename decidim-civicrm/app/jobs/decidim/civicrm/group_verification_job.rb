# frozen_string_literal: true

module Decidim
  module Civicrm
    class GroupVerificationJob < ApplicationJob
      queue_as :default

      def perform(groups, id, name, organization_id)
        civicrm_users = Decidim::Civicrm::Api::Request.new.users_in_group(id)
        uids = civicrm_users.map { |user| user.dig("api.User.get", "values", 0, "id") }
        user_ids = Decidim::Identity.where(decidim_organization_id: organization_id, uid: uids).pluck(:decidim_user_id)

        Decidim::User.where(id: user_ids).find_each do |user|
          authorization = Decidim::Authorization.find_by(user: user, name: "groups")

          authorization = Decidim::Authorization.create!(default_attributes(user, groups)) if authorization.blank?

          key = Decidim::Civicrm::Api::Group.name_to_key(name)
          metadata = authorization.metadata.merge(group: key)

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

      def default_attributes(user, groups)
        {
          user: user,
          name: "groups",
          metadata: default_metadata(groups),
          unique_id: Digest::SHA512.hexdigest(
            "#{user.id}-groups-#{Rails.application.secrets.secret_key_base}"
          )
        }
      end

      def default_metadata(_groups)
        { group: nil }
      end
    end
  end
end
