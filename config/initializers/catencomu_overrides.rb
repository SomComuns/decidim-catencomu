# frozen_string_literal: true

# check application.rb to see the middleware initialization

Rails.application.config.to_prepare do
  # tweak authentication for closed organizations
  Decidim::ForceAuthentication.include(Decidim::ForceAuthenticationOverride)
  # separate participatory processes in 2 menus (within or without a process group)
  Decidim::ParticipatoryProcess.include(Decidim::ParticipatoryProcessOverride)
  Decidim::ParticipatoryProcesses::ProcessFiltersCell.include(Decidim::ParticipatoryProcesses::ProcessFiltersCellOverride)
  Decidim::FiltersHelper.include(Decidim::FiltersHelperOverride)
end

Rails.application.config.after_initialize do
  # Creates a new menu next to Processes for ungrouped processes
  if Rails.application.secrets.scope_ungrouped_processes[:enabled]
    Decidim.menu :menu do |menu|
      path = ParticipatoryProcessesScoper::ALTERNATIVE_NAMESPACE
      key = Rails.application.secrets.scope_ungrouped_processes[:key] || path
      position = Rails.application.secrets.scope_ungrouped_processes[:position_in_menu]

      menu.item I18n.t(key, scope: "decidim.scope_ungrouped_processes"),
                Rails.application.routes.url_helpers.send("#{path}_path"),
                position: position,
                if: (
                  Decidim::ParticipatoryProcess
                  .unscoped
                  .where(organization: current_organization)
                  .where.not(decidim_participatory_process_group_id: nil)
                  .published
                  .any?
                ),
                active: :inclusive
    end
  end
end
