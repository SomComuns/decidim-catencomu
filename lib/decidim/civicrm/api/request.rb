# frozen_string_literal: true

module Decidim
  module Civicrm
    module Api
      class Request
        def initialize(url: nil, api_key: nil, key: nil, verify_ssl: true)
          @url = url || config[:url]
          @api_key = api_key || config[:api_key]
          @key = key || config[:key]
          @verify_ssl = verify_ssl
          @connection = Faraday.new(ssl: { verify: verify_ssl })
        end

        def get(extra_params = {})
          response = @connection.get @url do |request|
            request.params = request_params.merge(extra_params)
            request.params[:key] = @key if @key.present?
            request.params[:api_key] = @api_key if @api_key.present?
          end

          return raise Error, response.reason_phrase unless response.success?

          JSON.parse(response.body).to_h
        end

        def post(extra_params = {})
          response = @connection.post @url do |request|
            request.params = request_params.merge(extra_params)
            request.params[:key] = @key if @key.present?
            request.params[:api_key] = @api_key if @api_key.present?
          end

          return raise Error, response.reason_phrase unless response.success?

          JSON.parse(response.body).to_h
        end

        def get_contact(id)
          params = {
            entity: "Contact",
            contact_id: id,
            json: {
              :sequential => 1, # Present results as array, not hash
              :return => "roles,display_name",
              "api.Address.get" => { "return" => RegionalScope::FIELD_NAME } # Return the id of the Contact's Regional Scope
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
              sequential: 1 # Present results as array, not hash
            }.to_json
          }

          response = get(params)

          raise Error, "Malformed response in get_user: #{response.to_json}" unless response.has_key?("values")

          @user = response["values"].first

          return @user unless with_contact

          @contact = get_contact(@user["contact_id"])

          @user = @user.merge(@contact)
        end

        def fetch_groups
          params = {
            entity: "Group",
            json: {
              sequential: 1, # Present results as array, not hash
              options: { limit: 0 }, # Don't limit number of results
              return: "id, name, title, description, group_type, visibility",
              is_active: true # Only return active groups
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
              sequential: 1, # Present results as array, not hash
              options: { limit: 0 }, # Don't limit number of results
              group: group, # Group's "name" field value
              return: "id,display_name,group",
              "api.Usercat.get" => { "return" => "id" } # Return the Contact's related User ID
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
          Rails.application.secrets.verifications[:civicrm]
        end

        attr_reader :response
      end
    end
  end
end
