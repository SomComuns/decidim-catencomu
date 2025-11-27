# frozen_string_literal: true

module Decidim
  module CatcomuManagers
    module CivicrmGroupOverride
      extend ActiveSupport::Concern

      included do
        has_many :group_configs,
                 class_name: "Decidim::CatcomuManagers::GroupConfig",
                 foreign_key: "civicrm_default_group_id",
                 dependent: :nullify
      end
    end
  end
end
