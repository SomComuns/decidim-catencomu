# frozen_string_literal: true

# Eager loading: prevent N+1 on area when rendering the processes index.
# Upstream search_collection switched to published_processes.query and dropped .includes(:area).

Rails.application.config.to_prepare do
  Decidim::ParticipatoryProcesses::ParticipatoryProcessesController.class_eval do
    private

    def search_collection
      published_processes.query.includes(:area)
    end
  end
end
