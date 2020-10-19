# frozen_string_literal: true

require 'rails_helper'

describe 'Verify a user with CiViCRM', type: :system, with_authorization_workflows: ["civicrm_handler"] do
  let(:organization) { create :organization, available_authorizations: authorizations }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:authorizations) { ["civicrm_handler"] }

  before do
    switch_to_host(organization.host)
    sign_in user, scope: :user
    page.visit decidim_verifications.authorizations_path
  end

  it "shows" do
    click_link "CiViCRM"
    click_button "Send"
    expect(page).to have_content("You've been successfully authorized")
  end
end

