# frozen_string_literal: true

require "rails_helper"

describe "Visit_the_account_page" do
  let(:organization) { create :organization, external_domain_allowlist: %w(home.url registration.url) }
  let(:user) { create :user, :confirmed, organization: }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.account_path
  end

  it "has a link to home_url" do
    expect(page).to have_css("[href=\"#{Rails.application.secrets.participacio_url[I18n.locale]}\"]")
  end
end
