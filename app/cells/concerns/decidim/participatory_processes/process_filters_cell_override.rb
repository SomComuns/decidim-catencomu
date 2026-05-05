# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Builds filter URLs for the namespace currently active in ParticipatoryProcessesScoper.
    module ProcessFiltersCellOverride
      extend ActiveSupport::Concern

      included do
        alias_method :upstream_filter_link, :filter_link

        def filter_link(date_filter)
          namespace = Decidim::ParticipatoryProcess.scoped_groups_namespace
          return upstream_filter_link(date_filter) if namespace != ParticipatoryProcessesScoper::ALTERNATIVE_NAMESPACE

          Rails.application.routes.url_helpers.send("#{namespace}_path", **filter_params(date_filter))
        end
      end
    end
  end
end
