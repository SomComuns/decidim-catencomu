# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        class AuthorizationsController < Decidim::ApplicationController
          def new
            redirect_to_index
          end

          def edit
            return redirect_to_index unless (auth = authorization(false))

            byebug
            civicrm_users = Decidim::Civicrm::Api::Request.new.users_in_group(group_id)
            uids = civicrm_users.map { |user| user.dig("api.Usercat.get", "values", 0, "id") }

            redirect_to decidim_verifications.authorizations_path
          end

          private

          def redirect_to_index
            flash[:alert] = t("authorizations.new.no_action", scope: "decidim.groups.verification")
            redirect_to decidim_verifications.authorizations_path
          end

          def authorization(granted)
            Decidim::Verifications::Authorizations.new(organization: current_organization, user: current_user, granted: granted, name: :groups)&.first
          end

          def groups
            @groups ||= Decidim::Civicrm::Api::Request.new.fetch_groups
          end
        end
      end
    end
  end
end
