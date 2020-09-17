require "omniauth/civicrm"

if Rails.application.secrets.dig(:omniauth, :civicrm).present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :civicrm,
             Rails.application.secrets.dig(:omniauth, :civicrm, :client_id),
             Rails.application.secrets.dig(:omniauth, :civicrm, :client_secret),
             Rails.application.secrets.dig(:omniauth, :civicrm, :site),
             scope: "openid profile email"
  end
end
