module CivicrmApi
  module Models
    module User
      class << self
        def from_contact(json, address: false)
          {
            contact_id: json["contact_id"],
            email: json["email"],
            name: json["display_name"],
            nickname: json["nick_name"],
            roles: json["roles"],
            address: (Address.from_contact(json) if address)
          }
        end
        
        def from_user(json)
          {
            id: json["id"],
            contact_id: json["contact_id"],
            email: json["email"],
          }
        end
      end
    end
  end
end
    