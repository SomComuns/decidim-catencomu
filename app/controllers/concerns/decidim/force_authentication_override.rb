# frozen_string_literal: true

module Decidim
  module ForceAuthenticationOverride
    extend ActiveSupport::Concern

    included do
      private

      # Check for all paths that should be allowed even if the user is not yet
      # authorized
      def allow_unauthorized_path?
        return true if unauthorized_paths.any? { |path| /^#{path}/.match?(request.path) }

        # allow homepage
        return true if ["/", "/processes", "/#{ParticipatoryProcessesScoper::ALTERNATIVE_NAMESPACE}"].include? request.path

        # allow process groups
        return true if %r{^/processes_groups}.match? request.path

        false
      end
    end
  end
end
