# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module CivicrmGroups
        # This is an engine that implements the administration interface for
        # user authorization by civicrm group.
        class AdminEngine < ::Rails::Engine
          isolate_namespace Decidim::Civicrm::Verifications::CivicrmGroups::Admin

          paths["db/migrate"] = nil
          paths["lib/tasks"] = nil

          routes do
            resources :groups, only: :index do
              get :refresh, on: :member
            end

            root to: "groups#index"
          end
        end
      end
    end
  end
end
