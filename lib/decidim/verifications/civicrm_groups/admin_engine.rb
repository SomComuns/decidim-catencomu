# frozen_string_literal: true

module Decidim
  module Verifications
    module CivicrmGroups
      # This is an engine that implements the administration interface for
      # user authorization by civicrm group.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::CivicrmGroups::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resources :groups, only: :index do
            get :refresh, on: :collection
          end

          root to: "groups#index"
        end
      end
    end
  end
end
