Rails.application.config.to_prepare do
  Decidim::OfficialAuthorPresenter.include(Decidim::OfficialAuthorPresenterOverride)
end
