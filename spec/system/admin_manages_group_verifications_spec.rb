# frozen_string_literal: true

require "rails_helper"

describe "Admin manages group verifications", type: :system do
  let(:organization) { create(:organization) }

  let(:user) { create(:user, :admin, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    stub_groups_valid_request
  end

  it "shows index" do
    visit "/admin/groups"
    within ".civicrm-groups tbody" do
      within "tr:first-child" do
        expect(page.find("td:nth-child(1)")).to have_content "Administrators"
        expect(page.find("td:nth-child(2)")).to have_content "Administrators"
        expect(page.find("td:nth-child(3)")).to have_content "The users in this group are assigned admin privileges."
        expect(page.find("td:nth-child(4)")).to have_content "User and User Admin Only"
        expect(page.find("td:nth-child(5)")).to have_content "3"
      end
      within "tr:nth-child(2)" do
        expect(page.find("td:nth-child(1)")).to have_content "Another Group"
        expect(page.find("td:nth-child(2)")).to have_content "Another_Group"
        expect(page.find("td:nth-child(3)")).to have_content "..."
        expect(page.find("td:nth-child(4)")).to have_content "User and User Admin Only"
        expect(page.find("td:nth-child(5)")).to have_content "1337"
      end
    end
  end
end
