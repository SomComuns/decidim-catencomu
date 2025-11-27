# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::OfficialAuthorPresenter.include(Decidim::OfficialAuthorPresenterOverride)
end
