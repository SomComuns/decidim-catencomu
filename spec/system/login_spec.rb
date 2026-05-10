# frozen_string_literal: true

require "rails_helper"

describe "Visit_the_account_page" do
  let(:organization) { create(:organization, users_registration_mode:, external_domain_allowlist: %w(home.url registration.url)) }
  let(:user) { create(:user, organization:) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
    within "#main-bar" do
      click_on "Log in"
    end
  end

  shared_examples "shows external registration link" do
    it "has an external link to registration_url defined in catcomu.yml" do
      expect(page).to have_css("[href=\"#{Rails.application.config_for(:catcomu).registration_url[I18n.locale]}\"]")
    end
  end

  context "when users_registration_mode is disabled" do
    let(:users_registration_mode) { "disabled" }

    include_examples "shows external registration link"
  end

  context "when users_registration_mode is existing" do
    let(:users_registration_mode) { "existing" }

    include_examples "shows external registration link"
  end
end
