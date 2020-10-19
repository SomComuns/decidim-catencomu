module Civicrm
  module Api
    module Address
      class << self
        def from_contact(json)
          {
            country: json["country"],
            city: json["city"],
            postal_code: json["postal_code"],
            street_address: json["street_address"],
            state_province_name: json["state_province_name"],
            state_province: json["state_province"],
            supplemental_address_1: json["supplemental_address_1"],
            supplemental_address_2: json["supplemental_address_2"],
            supplemental_address_3: json["supplemental_address_3"],
          }
        end
      end
    end
  end
end