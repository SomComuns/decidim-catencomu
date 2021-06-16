# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::ForceAuthentication.include(Decidim::ForceAuthenticationOverride)
end
