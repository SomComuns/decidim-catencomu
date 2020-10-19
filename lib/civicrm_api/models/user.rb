# frozen_string_literal: true

module CivicrmApi
  module Models
    module User
      ROLES = { "6" => :interested, "7" => :inscribed }.freeze

      class << self
        def from_contact(json, with_address: false)
          {
            contact_id: json["contact_id"],
            email: json["email"],
            name: json["display_name"],
            nickname: json["name"],
            role: main_role(json),
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

        def main_role(json)
          roles = relevant_roles(json["roles"])

          return nil if roles.count.zero?

          raise CivicrmApi::Error, "Too many relevant roles found for user with email #{json["email"]}" if roles.count > 1

          roles.first
        end

        def relevant_roles(roles)
          map_roles(roles) & ROLES.values
        end

        def map_roles(roles)
          return [] if roles.blank?

          roles.map { |id, _name| ROLES[id] }.compact
        end
      end
    end
  end
end
