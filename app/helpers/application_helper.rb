# frozen_string_literal: true

module ApplicationHelper
  def civicrm_user?(user)
    user.identities.find_by(provider: Decidim::Verifications::Civicrm::PROVIDER_NAME).present?
  end
end
