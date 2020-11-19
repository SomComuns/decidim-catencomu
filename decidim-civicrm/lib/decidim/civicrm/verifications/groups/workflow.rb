# frozen_string_literal: true

Decidim::Verifications.register_workflow(:groups) do |workflow|
  workflow.engine = Decidim::Civicrm::Verifications::Groups::Engine
  workflow.admin_engine = Decidim::Civicrm::Verifications::Groups::AdminEngine
end
