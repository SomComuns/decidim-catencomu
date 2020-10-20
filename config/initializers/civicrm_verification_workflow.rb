# frozen_string_literal: true

Decidim::Verifications.register_workflow(:civicrm) do |workflow|
  workflow.form = "Decidim::Verifications::Civicrm"

  workflow.options do |options|
    options.attribute :role, type: :enum, choices: -> { Decidim::Civicrm::Api::User::RELEVANT_ROLES + [Decidim::Civicrm::Api::User::ROLE_OTHER] }
  end
end
