# frozen_string_literal: true

module Decidim
  module Civicrm
    module Api
      module Group
        class << self
          def parse_groups(json)
            json.map { |group| parse_group(group) }
          end

          def parse_group(json)
            {
              id: json["id"],
              name: json["name"],
              title: json["title"],
              description: json["description"],
              visibility: json["visibility"],
              group_type: json["group_type"],
              is_active: json["is_active"],
              is_hidden: json["is_hidden"],
              is_reserved: json["is_reserved"]
            }
          end
        end
      end
    end
  end
end
