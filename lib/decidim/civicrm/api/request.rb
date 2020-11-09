# frozen_string_literal: true

module Decidim
  module Civicrm
    module Api
      class Request
        def initialize(params = {})
          @params = params
        end

        def get(extra_params = {})
          response ||= Faraday.get config[:url] do |request|
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
              :return => "roles",
              "api.Address.get" => { "return" => RegionalScope::FIELD_NAME }
            }
          }

          response = get(params)
          raise Error, "Malformed response in get_contact: #{response.to_json}" unless response.has_key?("values")

          response["values"][id.to_s]
        end

        def get_user(id, with_contact: true)
          response = get(entity: "User", id: id)

          raise Error, "Malformed response in get_user: #{response.to_json}" unless response.has_key?("values")

          @user = response["values"][id.to_s]

          return @user unless with_contact

          @contact = get_contact(@user["contact_id"])
          @user.merge(@contact)
          @user.merge(cn_member: in_group?(@user["contact_id"], User::CN_GROUP))
        end

        def in_group?(id, group)
          params = {
            entity: "Contact",
            contact_id: id,
            json: {
              group: group,
              return: "id,display_name"
            }
          }

          response = get(params)

          raise Error, "Malformed response in in_group?: #{response.to_json}" unless response.has_key?("values")

          return false unless response["values"].count.positive?

          return "1" if response["values"].values.first["contact_id"]&.to_i == id.to_i
        end

        private

        def request_params
          @params.reverse_merge(
            action: "Get",
            api_key: config[:api_key],
            key: config[:secret],
            json: @params.fetch(:json, true)
          )
        end

        def config
          Rails.application.secrets.verifications.dig(:civicrm)
        end

        attr_reader :response
      end
    end
  end
end
