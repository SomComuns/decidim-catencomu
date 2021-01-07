# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        # This is an engine that implements the interface for
        # user authorization by civicrm group.
        class Engine < ::Rails::Engine
          isolate_namespace Decidim::Civicrm::Verifications::Groups

          paths["db/migrate"] = nil
          paths["lib/tasks"] = nil

          routes do
            root to: "authorizations#new"
          end
        end
      end
    end
  end
end
