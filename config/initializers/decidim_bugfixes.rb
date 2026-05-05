# frozen_string_literal: true

# Eager-loads :area in the processes index search collection.

Rails.application.config.to_prepare do
  Decidim::ParticipatoryProcesses::ParticipatoryProcessesController.class_eval do
    private

    def search_collection
      published_processes.query.includes(:area)
    end
  end
end
