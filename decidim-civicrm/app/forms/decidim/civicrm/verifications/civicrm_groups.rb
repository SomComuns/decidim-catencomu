# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      class CivicrmGroups < Decidim::Civicrm::Verifications::Civicrm
        PROVIDER_NAME = "groups"

        validate :user_valid

        def metadata
          return super unless response
byebug
          super.merge(
            contact_id: response[:contact_id],
            role: response[:role],
            regional_scope: response[:regional_scope]
          )
        end

        def response
          return nil if uid.blank?

          return @response if defined?(@response)

          json = Decidim::Civicrm::Api::Request.new.get_user(uid)
          @response = Decidim::Civicrm::Api::Request.new.user_groups(json["contact_id"])
        end
      end
    end
  end
end
