module CivicrmApi
  class Request
    def initialize(params = {})
      @params = params
    end

    def get(extra_params = {})
      response ||= Faraday.get config[:url] do |request|
        request.params = request_params.merge(extra_params)
      end

      JSON.parse(response.body).to_h
    end

    def get_contact(id)
      get(entity: "Contact", contact_id: id, return: "roles")["values"][id.to_s]
    end
    
    def get_user(id, with_contact: true)
      @user = get(entity: "User", id: id)["values"][id.to_s]
      
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
