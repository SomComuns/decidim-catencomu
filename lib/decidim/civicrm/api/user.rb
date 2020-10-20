# frozen_string_literal: true

module Decidim
  module Civicrm
    module Api
      module User
        ROLES = {
          "2" => :authenticated,
          "3" => :administrator,
          "5" => :catencomu_admin,
          "6" => :interested,
          "7" => :inscribed
        }.freeze

        RELEVANT_ROLES = [:interested, :inscribed].freeze
        ROLE_OTHER = :other

        class << self
          def from_contact(json, with_address: false)
            {
              contact_id: json["contact_id"],
              email: json["email"],
              name: json["display_name"],
              nickname: json["name"],
              role: role(json),
              address: (Address.from_contact(json) if with_address)
            }
          end

          def from_user(json)
            {
              id: json["id"],
              contact_id: json["contact_id"],
              email: json["email"]
            }
          end

          def role(json)
            roles = relevant_roles(json["roles"])

            return raise Error, "Too many relevant roles found for user with email #{json["email"]}" if roles.count > 1
            return ROLE_OTHER if roles.count.zero?

            roles.first
          end

          def relevant_roles(roles)
            map_response_roles(roles) & RELEVANT_ROLES
          end

          def map_response_roles(roles)
            roles.to_a.map { |key, _value| ROLES[key] }.compact
          end
        end
      end
    end
  end
end
