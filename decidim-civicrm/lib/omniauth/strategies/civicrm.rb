# frozen_string_literal: true

require "omniauth-oauth2"
require "open-uri"
require "decidim/civicrm/api"

module OmniAuth
  module Strategies
    class Civicrm < OmniAuth::Strategies::OAuth2
      args [:client_id, :client_secret, :site]

      option :name, :civicrm
      option :site, nil
      option :client_options, {}

      uid do
        raw_info["sub"]
      end

      info do
        # typical response:
        # {"id"=>"23101", "name"=>"test111@platoniq.net", "email"=>"test111@platoniq.net", "contact_id"=>"23101", "display_name"=>"test test", "api.Address.get"=>{"is_error"=>0, "version"=>3, "count"=>0, "values"=>[]}, "roles"=>{"2"=>"authenticated user", "3"=>"administrator"}}
        json = Decidim::Civicrm::Api::Request.new.get_user(uid)
        # typical response:
        # {:contact_id=>"23101", :email=>"test111@platoniq.net", :name=>"test test", :nickname=>"test111@platoniq.net", :role=>nil, :regional_scope=>nil}
        user = Decidim::Civicrm::Api::User.from_contact(json)

        {
          name: user[:name],
          nickname: user[:nickname],
          email: raw_info["email"],
          image: raw_info["picture"],
          contact_id: user[:contact_id],
          role: user[:role],
          regional_scope: user[:regional_scope]
        }
      end
      
      def client
        options.client_options[:site] = options.site

        locale_path_segment = "/#{request[:locale]}/"

        options.client_options[:authorize_url] = URI.join(options.site, locale_path_segment, "oauth2/authorize").to_s
        options.client_options[:token_url] = URI.join(options.site, locale_path_segment, "oauth2/token").to_s
        super
      end

      def raw_info
        @raw_info ||= access_token.get("/oauth2/UserInfo").parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
