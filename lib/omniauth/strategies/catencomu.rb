# frozen_string_literal: true

require "omniauth-oauth2"
require "open-uri"

module OmniAuth
  module Strategies
    class Catencomu < OmniAuth::Strategies::OAuth2
      args [:client_id, :client_secret, :site]

      option :name, :catencomu
      option :site, nil
      option :client_options, {}

      uid do
        raw_info["id"]
      end

      info do
        {
          email: raw_info["email"],
          nickname: raw_info["nickname"],
          name: raw_info["name"],
          image: raw_info["image"]
        }
      end

      # params:
      #   client_id: debugger_client_id
      #   redirect_uri: https://oauthdebugger.com/debug
      #   scope: openid
      #   response_type: code
      #   response_mode: form_post
      #   nonce: <nonce_random_value>
      #   state: <state_value>

      def client
        options.client_options[:site] = options.site
        options.client_options[:authorize_url] = options.authorize_url
        options.client_options[:token_url] = options.token_url
        super
      end

      def raw_info
        byebug
        @raw_info ||= access_token.get("/oauth/me").parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end