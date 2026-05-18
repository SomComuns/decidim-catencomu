# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::ForceAuthentication.class_eval do
    def ensure_authenticated!
      return true unless current_organization&.force_users_to_authenticate_before_access_organization

      # allow homepage
      return true if %w(/ /processes).include? request.path

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

# Decidim::DecidimAwesome.configure do |config|
#   config.scoped_admins = :disabled
# end
