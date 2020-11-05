# frozen_string_literal: true

Decidim::Verifications.register_workflow(:civicrm_groups) do |workflow|
  workflow.engine = Decidim::Civicrm::Verifications::CivicrmGroups::Engine
  workflow.admin_engine = Decidim::Civicrm::Verifications::CivicrmGroups::AdminEngine
end
