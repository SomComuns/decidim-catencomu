require "omniauth/catencomu"

if Rails.application.secrets.dig(:omniauth, :catencomu).present?
  Devise.setup do |config|
    config.omniauth :catencomu,
                    Rails.application.secrets.dig(:omniauth, :catencomu, :client_id),
                    Rails.application.secrets.dig(:omniauth, :catencomu, :client_secret),
                    Rails.application.secrets.dig(:omniauth, :catencomu, :site_url),
                    scope: :openid
  end
end
