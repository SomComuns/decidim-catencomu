module CivicrmApi
  class Request
    def initialize(params = {})
      @params = params
    end

    def get(extra_params = {})
      response ||= Faraday.get config[:url] do |request|
        request.params = request_params.merge(extra_params)
      end

      if response.success?
        JSON.parse(response.body).to_h
      else
        raise CivicrmApi::Error.new(response.reason_phrase)
      end
    end

    def get_contact(id)
      response = get(entity: "Contact", contact_id: id, return: "roles")
      
      unless response.has_key("values")
        raise CivicrmApi::Error.new("Malformed response in get_contact: #{response.to_json.to_s}")
      end
      
      response["values"][id.to_s]
    end
    
    def get_user(id, with_contact: true)
      response = get(entity: "User", id: id)
      
      unless response.has_key("values")
        raise CivicrmApi::Error.new("Malformed response in get_user: #{response.to_json.to_s}")
      end
      
      @user = response["values"][id.to_s]

      return @user unless with_contact

      @contact = get_contact(@user["contact_id"])
      @user.merge(@contact)
    end

    private

    def request_params
      @params.reverse_merge({
        action: "Get",
        api_key: config[:api_key],
        key: config[:secret],
        json: @params.fetch(:json, true)
      })
    end

    def config
      Rails.application.secrets.verifications.dig(:civicrm)
    end

    attr_reader :response
  end
end
