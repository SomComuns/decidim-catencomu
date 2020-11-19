# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module CivicrmGroups
        # This is an engine that performs an example user authorization.
        class Engine < ::Rails::Engine
          isolate_namespace Decidim::Civicrm::Verifications::CivicrmGroups

          paths["db/migrate"] = nil
          paths["lib/tasks"] = nil

          routes do
            resource :authorizations, only: [:new], as: :authorization

            root to: "authorizations#new"
          end
        end
      end
    end
  end
end
