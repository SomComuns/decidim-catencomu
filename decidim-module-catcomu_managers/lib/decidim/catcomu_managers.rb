# frozen_string_literal: true

require "decidim/catcomu_managers/admin"
require "decidim/catcomu_managers/admin_engine"

module Decidim
  module CatcomuManagers
    include ActiveSupport::Configurable

    config_accessor :manual_link do
      "https://raw.githubusercontent.com/Platoniq/decidim-catencomu/main/catcomu-managers/docs/manual-cat_v1.1.pdf"
    end

    config_accessor :contact_data do
      ""
    end
  end
end
