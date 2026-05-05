# frozen_string_literal: true

if defined?(Decidim::CatcomuManagers)
  Decidim::CatcomuManagers.configure do |config|
    config.contact_data = Rails.application.config_for(:catcomu).managers[:contact_data]
  end
end
