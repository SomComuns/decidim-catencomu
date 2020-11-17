# frozen_string_literal: true

module Decidim
  module Verifications
    module CivicrmGroups
      class AuthorizationsController < Decidim::Verifications::ApplicationController 
        def new
          flash[:alert] = t("authorizations.new.no_action", scope: "decidim.civicrm.verifications.civicrm_groups")
          redirect_to decidim_verifications.authorizations_path
        end
      end
    end
  end
end