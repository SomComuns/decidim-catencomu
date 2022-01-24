# frozen_string_literal: true

Catcomu::Managers.configure do |config|
  config.contact_data = Rails.application.secrets.managers[:contact_data]
end
