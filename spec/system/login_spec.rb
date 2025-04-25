# frozen_string_literal: true

require "rails_helper"

describe "Visit_the_account_page" do
  let(:organization) { create :organization, users_registration_mode: "disabled", external_domain_whitelist: %w(home.url registration.url) }
  let(:user) { create :user, organization: }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
    click_on "Sign In"
  end

  context "when sign_up is disabled" do
    it "has an external link to registration_url defined in secrets.yml" do
      expect(page).to have_css("[href=\"#{Rails.application.secrets.registration_url[I18n.locale]}\"]")
    end
  end
end
