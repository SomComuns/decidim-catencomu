# frozen_string_literal: true

require "rails_helper"

describe "Visit the account page", type: :system do
  let(:organization) { create :organization }
  let(:user) { create :user, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.account_path
  end

  it "has a link to home_url " do
    expect(page).to have_selector("[href=\"#{Rails.application.secrets.participacio_url[I18n.locale]}\"]")
  end
end
