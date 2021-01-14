# frozen_string_literal: true

require "rails_helper"

describe "Visit the account page", type: :system do
  let(:organization) { create :organization, users_registration_mode: "disabled" }
  let(:user) { create :user, organization: organization }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
    click_link "Sign In"
  end

  context "when sign_up is disabled" do
    it "has an external link to registration_url defined in secrets.yml" do
      expect(page).to have_selector("[href=\"#{Rails.application.secrets.registration_url[I18n.locale]}\"]")
    end
  end
end
