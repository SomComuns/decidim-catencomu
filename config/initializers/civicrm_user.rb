Decidim::User.class_eval do
  def civicrm?
    identities.find_by(organization: organization, provider: Decidim::Verifications::Civicrm::PROVIDER_NAME).present?
  end
end