# frozen_string_literal: true

require "rails_helper"
require "decidim/proposals/test/factories"
require "decidim/meetings/test/factories"

describe "Restrict actions by CiviCRM groups verification", type: :system do
  let(:handler_name) { "groups" }
  let(:manifest_name) { "proposals" }
  let(:options) { {} }
  let(:authorization_options) do
    {
      authorization_handlers: {
        handler_name => { "options" => options }
      }
    }
  end

  let!(:organization) do
    create(:organization, available_authorizations: %w(groups))
  end

  let(:participatory_space) do
    create(:participatory_process, :with_steps, organization: organization)
  end

  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:proposal) { create(:proposal, component: proposals_component) }
  let!(:meeting) { create(:meeting, component: meetings_component) }

  let!(:meetings_component) do
    create(
      :meeting_component,
      manifest: Decidim.find_component_manifest("meetings"),
      manifest_name: :meetings,
      participatory_space: participatory_space,
      permissions: { join: authorization_options }
    )
  end

  let!(:proposals_component) do
    create(
      :proposal_component,
      :with_creation_enabled,
      manifest: Decidim.find_component_manifest("proposals"),
      manifest_name: :proposals,
      participatory_space: participatory_space,
      permissions: { create: authorization_options }
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  after do
    expect_no_js_errors
  end

  describe "Group Verification" do
    let(:options) { { "group" => "group_1" } }
    let(:metadata) { { "groups" => %w(group_1 group_2) } }
    let(:wrong_metadata) { { "groups" => %w(group_2 group_3) } }

    context "when user is authorized" do
      let!(:authorization) { create(:authorization, user: user, name: handler_name, metadata: metadata) }

      it "allows to create a proposal" do
        visit_proposal
        expect(page).to have_link "New proposal"

        click_link "New proposal"
        expect(page).to have_selector ".new_proposal"
      end

      it "allows to join a meeting" do
        visit_meeting
        expect(page).to have_link "Join"

        click_link "Join"
        expect(page).to have_content "Blabla"
      end
    end

    context "when user is authorized with wrong metadata" do
      let!(:authorization) { create(:authorization, user: user, name: handler_name, metadata: wrong_metadata) }

      it "does not allow to create a proposal" do
        visit_proposal
        expect(page).not_to have_link "New proposal"
      end

      it "does not allow to join a meeting" do
        visit_meeting
        expect(page).not_to have_link "Join"
      end
    end

    context "when user is not authorized" do
      let!(:authorization) { nil }

      it "does not allow to create a proposal" do
        visit_proposal
        expect(page).not_to have_link "New proposal"
      end

      it "does not allow to join a meeting" do
        visit_meeting
        expect(page).not_to have_link "Join"
      end
    end
  end

  def visit_proposal
    page.visit resource_locator(proposal).path
  end

  def visit_meeting
    page.visit resource_locator(meeting).path
  end
end
