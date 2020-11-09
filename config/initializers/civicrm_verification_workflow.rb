# frozen_string_literal: true

Decidim::Verifications.register_workflow(:civicrm) do |workflow|
  workflow.form = "Decidim::Verifications::Civicrm"

  workflow.options do |options|
    options.attribute :cn_member, type: :boolean, default: false
    options.attribute :role, type: :enum, choices: -> { Decidim::Civicrm::Api::User::ROLES.values.map(&:to_s) }
    options.attribute :regional_scope, type: :enum, choices: -> { Decidim::Civicrm::Api::RegionalScope::ALL.keys.map(&:to_s) }
  end
end
