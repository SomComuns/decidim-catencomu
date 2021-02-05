# frozen_string_literal: true

require "rails_helper"

describe "The main menu", type: :system, perform_enqueued: true do
  let(:organization) { create :organization }
  let!(:process) { create :participatory_process, organization: organization }

  before do
    switch_to_host(organization.host)
  end

  context "when visiting the home page" do
    before do
      visit decidim.root_path
    end

    it "only renders the home element as active" do
      within ".main-nav" do
        expect(page.find(".main-nav__link:first-child")).to match_selector(".main-nav__link--active")
        expect(page.find(".main-nav__link:nth-child(2)")).not_to match_selector(".main-nav__link--active")
      end
    end
  end

  context "when visiting another page" do
    before do
      visit decidim.root_path
      click_link "Processes"
    end

    it "only renders the processes element as active" do
      within ".main-nav" do
        expect(page.find(".main-nav__link:first-child")).not_to match_selector(".main-nav__link--active")
        expect(page.find(".main-nav__link:nth-child(2)")).to match_selector(".main-nav__link--active")
      end
    end
  end

  context "when clicking on the 'home' item in menu" do
    it "loads the url defined in secrets.yml" do
      visit decidim.root_path
      click_link "Home"
      expect(current_url).to match(Rails.application.secrets.home_url)
    end
  end
end
