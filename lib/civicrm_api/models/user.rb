module CivicrmApi
  module Models
    module User
      class << self
        ROLES = { 6 => :interested}

        def from_contact(json, with_address: false)
          {
            contact_id: json["contact_id"],
            email: json["email"],
            name: json["display_name"],
            nickname: json["nick_name"],
            roles: map_roles(json["roles"]),
            user_role: main_role(json["roles"]),
            address: (Address.from_contact(json) if with_address)
          }
        end
        
        def from_user(json)
          {
            id: json["id"],
            contact_id: json["contact_id"],
            email: json["email"],
          }
        end

        def main_role(json)
          roles = relevant_roles(json["roles"])
          if roles.count == 1
            return roles.first
          elsif roles.count.zero?
            return nil
          else
            raise Exception.new("Too many relevant roles found for user with email #{json["email"]}")
          end
        end

        def relevant_roles(roles)
          relevant_roles = map_roles(roles) & ROLES.values
        end

        def map_roles(roles)
          return [] if roles.blank?

          roles.map { |id, name| ROLES[id] }.compact
        end
      end
    end
  end
end
    