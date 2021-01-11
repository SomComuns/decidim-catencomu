# frozen_string_literal: true

require "rails_helper"

describe "Block email editing", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when signing up with oauth" do
    it "cannot change email" do
      visit decidim.user_civicrm_omniauth_callback_path
      expect(page.find("#user_email")).to be_readonly
    end
  end

  context "when visiting account page" do
    let(:user) { create(:user, organization: organization) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
    end

    context "when user is a civicrm user" do
      let!(:identity) { create(:identity, user: user, provider: Decidim::Verifications::Civicrm::PROVIDER_NAME) }

      it "cannot change email" do
        visit decidim.account_path
        expect(page.find("#user_email")).to be_readonly
      end
    end

    context "when user is not a civicrm user" do
      it "can change email" do
        visit decidim.account_path
        expect(page.find("#user_email")).not_to be_readonly
      end
    end
  end
end
