# frozen_string_literal: true

if Rails.application.secrets.dig(:omniauth, :civicrm).present?
  Decidim::Civicrm.omniauth =   {
    client_id: Rails.application.secrets.dig(:omniauth, :civicrm, :client_id),
    client_secret: Rails.application.secrets.dig(:omniauth, :civicrm, :client_secret),
    site: Rails.application.secrets.dig(:omniauth, :civicrm, :site)
  }
end
