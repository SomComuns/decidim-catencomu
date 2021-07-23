# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        # This is an engine that implements the administration interface for
        # user authorization by civicrm group.
        class AdminEngine < ::Rails::Engine
          isolate_namespace Decidim::Civicrm::Verifications::Groups::Admin

          paths["db/migrate"] = nil
          paths["lib/tasks"] = nil

          routes do
            resources :participatory_process_group_assignments, except: [:show, :edit, :update]

            post ":id", to: "groups#update", as: :group

            root to: "groups#index"
          end
        end
      end
    end
  end
end
