# frozen_string_literal: true

module Decidim
  module Civicrm
    module Api
      class Request
        def get(extra_params = {})
          response = Faraday.get config[:url] do |request|
            request.params = request_params.merge(extra_params)
          end

          return raise Error, response.reason_phrase unless response.success?

          JSON.parse(response.body).to_h
        end

        def get_contact(id)
          params = {
            entity: "Contact",
            contact_id: id,
            json: {
              :sequential => 1,
              :return => "roles,display_name",
              "api.Address.get" => { "return" => RegionalScope::FIELD_NAME }
            }.to_json
          }

          response = get(params)
          raise Error, "Malformed response in get_contact: #{response.to_json}" unless response.has_key?("values")

          response["values"].first
        end

        def get_user(id, with_contact: true)
          params = {
            entity: "User",
            id: id,
            json: {
              sequential: 1
            }.to_json
          }

          response = get(params)

          raise Error, "Malformed response in get_user: #{response.to_json}" unless response.has_key?("values")

          @user = response["values"].first

          return @user unless with_contact

          @contact = get_contact(@user["contact_id"])

          @user = @user.merge(@contact)
          @user = @user.merge(cn_member: in_group?(@user["contact_id"], User::CN_GROUP))
        end

        def fetch_groups
          params = {
            entity: "Group",
            json: {
              sequential: 1,
              return: "id, name, title, description, group_type"
            }.to_json
          }

          response = get(params)

          raise Error, "Malformed response in fetch_groups: #{response.to_json}" unless response.has_key?("values")

          Group.parse_groups(response["values"])
        end

        def users_in_group(group)
          params = {
            entity: "Contact",
            json: {
              sequential: 1,
              options: { limit: 0 },
              group: group,
              return: "id,display_name,group",
              "api.User.get" => { "return" => "id" },
            }.to_json
          }

          response = get(params)

          raise Error, "Malformed response in users_in_group: #{response.to_json}" unless response.has_key?("values")

          response["values"]
        end

        def in_group?(id, group)
          params = {
            entity: "Contact",
            json: {
              sequential: 1,
              contact_id: id,
              group: group,
              return: "id,display_name,group"
            }.to_json
          }

          response = get(params)

          raise Error, "Malformed response in in_group?: #{response.to_json}" unless response.has_key?("values")

          return false unless response["values"].count.positive?

          contact_id = response["values"].first["contact_id"]

          contact_id.to_i == id.to_i ? "1" : false
        end

        private

        def request_params
          {
            action: "Get",
            api_key: config[:api_key],
            key: config[:secret]
          }
        end

        def config
          Rails.application.secrets.verifications.dig(:civicrm)
        end

        attr_reader :response
      end
    end
  end
end
