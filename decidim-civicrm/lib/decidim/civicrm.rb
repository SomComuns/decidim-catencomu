# frozen_string_literal: true

require "decidim/civicrm/verifications/groups/admin"
require "decidim/civicrm/verifications/groups/admin_engine"
require "decidim/civicrm/verifications/groups/engine"
require "decidim/civicrm/verifications/groups/groups_action_authorizer"

module Decidim
  # This namespace holds the logic of the `Civicrm` component. This component
  # allows users to create civicrm in a participatory space.
  module Civicrm
    include ActiveSupport::Configurable

    # setup a hash with :client_id, :client_secret and :site to enable omniauth authentication
    config_accessor :omniauth do
      {
        client_id: nil,
        client_secret: nil,
        site: nil
      }
    end

    # authorizations enabled
    config_accessor :authorizations do
      [:civicrm, :groups]
    end
  end
end
