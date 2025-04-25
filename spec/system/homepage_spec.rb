# frozen_string_literal: true

require "rails_helper"

describe "Visit_the_homepage", perform_enqueued: true do
  let(:organization) { create :organization, external_domain_whitelist: %w(home.url registration.url) }

  before do
    switch_to_host(organization.host)
  end

  it "renders the home page" do
    visit decidim.root_path
    expect(page).to have_content("Home")
  end

  context "when clicking on the 'home' item in menu" do
    it "loads the url defined in secrets.yml" do
      visit decidim.root_path
      click_on "Home"
      expect(current_url).to match(Rails.application.secrets.home_url)
    end
  end
end
