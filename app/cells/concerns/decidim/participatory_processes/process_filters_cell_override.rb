# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ProcessFiltersCellOverride
      extend ActiveSupport::Concern

      included do
        def filter_link(date_filter, type_filter = nil)
          current_participatory_processes_path(date_filter, type_filter)
        end

        private

        # use the alternate url for generating filters if we are scoped
        def current_participatory_processes_path(date_filter, type_filter)
          if Decidim::ParticipatoryProcess.scoped_groups_namespace == ParticipatoryProcessesScoper::ALTERNATIVE_NAMESPACE
            return alternative_filter_link(Decidim::ParticipatoryProcess.scoped_groups_namespace, date_filter)
          end

          normal_filter_link(date_filter, type_filter)
        end

        def alternative_filter_link(key, filter)
          Rails.application.routes.url_helpers.send("#{key}_path", filter)
        end

        def normal_filter_link(date_filter, type_filter)
          Decidim::ParticipatoryProcesses::Engine
            .routes
            .url_helpers
            .participatory_processes_path(**filter_params(date_filter, type_filter))
        end
      end
    end
  end
end
