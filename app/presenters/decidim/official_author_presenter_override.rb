# frozen_string_literal: true

module Decidim
  module OfficialAuthorPresenterOverride
    extend ActiveSupport::Concern

    included do
      def avatar_url(_variant = nil)
        ActionController::Base.helpers.asset_pack_path("media/images/logo_catencomu.svg")
      end
    end
  end
end
