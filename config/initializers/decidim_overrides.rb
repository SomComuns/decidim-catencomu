# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::OfficialAuthorPresenter.include(Decidim::OfficialAuthorPresenterOverride)
  Decidim::Meetings::Directory::MeetingsController.include(MeetingsControllerOverride)
  Decidim::ParticipatoryProcesses::ProcessFiltersCell.include(Decidim::ParticipatoryProcesses::ProcessFiltersCellOverride)
end
