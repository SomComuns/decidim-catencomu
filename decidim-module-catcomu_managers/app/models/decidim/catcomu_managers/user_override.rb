module Decidim
  module CatcomuManagers
    module UserOverride
      extend ActiveSupport::Concern

      included do
        alias_method :original_admin_terms_accepted?, :admin_terms_accepted?

        def admin_terms_accepted?
          return true unless attributes["admin"]

          original_admin_terms_accepted?
        end
      end
    end
  end
end
