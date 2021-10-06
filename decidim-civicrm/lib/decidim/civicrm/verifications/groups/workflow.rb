# frozen_string_literal: true

Decidim::Verifications.register_workflow(:groups) do |workflow|
  workflow.engine = Decidim::Civicrm::Verifications::Groups::Engine
  workflow.admin_engine = Decidim::Civicrm::Verifications::Groups::AdminEngine
  workflow.action_authorizer = "Decidim::Civicrm::Verifications::Groups::GroupsActionAuthorizer"

  workflow.options do |options|
    options.attribute :group, type: :enum, choices: -> { Decidim::Civicrm::Api::Request.new.fetch_groups.map { |g| g[:name].downcase.to_sym } }
  end
end
