# frozen_string_literal: true

require "omniauth-oauth2"
require "open-uri"

module OmniAuth
  module Strategies
    class Civicrm < OmniAuth::Strategies::OAuth2
      args [:client_id, :client_secret, :site]

      option :name, :civicrm
      option :site, nil
      option :client_options, {}

      uid do
        raw_info["id"]
      end

      info do
        {
          email: raw_info["email"],
          nickname: raw_info["preferred_username"],
          name: raw_info["name"],
          image: raw_info["picture"],
          role: raw_info["role"],
        }
      end

      def client
        options.client_options[:site] = options.site
        options.client_options[:authorize_url] = URI.join(options.site, "/oauth2/authorize").to_s
        options.client_options[:token_url] = URI.join(options.site, "/oauth2/token").to_s
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