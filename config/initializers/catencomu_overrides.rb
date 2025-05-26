# frozen_string_literal: true

# check application.rb to see the middleware initialization

Rails.application.config.to_prepare do
  Decidim::ForceAuthentication.class_eval do
    def ensure_authenticated!
      return true unless current_organization&.force_users_to_authenticate_before_access_organization

      # allow homepage
      return true if ["/", "/processes", "/#{ParticipatoryProcessesScoper::ALTERNATIVE_NAMESPACE}"].include? request.path

      # allow process groups
      return true if %r{^/processes_groups}.match? request.path

      # Next stop: Check whether auth is ok
      unless user_signed_in?
        flash[:warning] = t("actions.login_before_access", scope: "decidim.core")
        redirect_to decidim.new_user_session_path
      end
    end
  end
end
Rails.application.config.after_initialize do
  # Creates a new menu next to Processes for ungrouped processes
  if Rails.application.secrets.scope_ungrouped_processes[:enabled]

    def add_menu_item(menu, position = nil)
      path = ParticipatoryProcessesScoper::ALTERNATIVE_NAMESPACE
      key = Rails.application.secrets.scope_ungrouped_processes[:key] || path
      position = Rails.application.secrets.scope_ungrouped_processes[:position_in_menu] if position.nil?

      menu.add_item :ungrouped_participatory_processes,
                    I18n.t(key, scope: "decidim.scope_ungrouped_processes"),
                    Rails.application.routes.url_helpers.send("#{path}_path"),
                    position:,
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
    Decidim.menu :menu do |menu|
      add_menu_item(menu)
    end
    Decidim.menu :home_content_block_menu do |menu|
      add_menu_item(menu, 20)
    end
  end
end

# Decidim::DecidimAwesome.configure do |config|
#   config.scoped_admins = :disabled
# end
