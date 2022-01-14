# frozen_string_literal: true

require "catcomu/managers/admin"
require "catcomu/managers/admin_engine"

module Catcomu
  module Managers
    include ActiveSupport::Configurable

    config_accessor :manual_link do
      "https://raw.githubusercontent.com/Platoniq/decidim-catencomu/main/catcomu-managers/docs/managers-manual.pdf"
    end
  end
end
