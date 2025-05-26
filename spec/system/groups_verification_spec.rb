# frozen_string_literal: true

require "rails_helper"
require "decidim/proposals/test/factories"
require "decidim/meetings/test/factories"

describe "Restrict_actions_by_CiviCRM_groups_verification" do
  let(:handler_name) { "civicrm_groups" }
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
    create(:organization, available_authorizations: %w(civicrm_groups))
  end

  let(:participatory_space) do
    create(:participatory_process, :with_steps, organization:)
  end

  let!(:user) { create(:user, :confirmed, organization:) }

  let!(:meeting) { create(:meeting, :published, component: meetings_component, registrations_enabled: true) }

  let!(:meetings_component) do
    create(
      :meeting_component,
      manifest: Decidim.find_component_manifest("meetings"),
      manifest_name: :meetings,
      participatory_space:,
      permissions: { join: authorization_options }
    )
  end

  let!(:proposals_component) do
    create(
      :proposal_component,
      :with_creation_enabled,
      manifest: Decidim.find_component_manifest("proposals"),
      manifest_name: :proposals,
      participatory_space:,
      permissions: { create: authorization_options }
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "Group Verification" do
    let(:options) { { "groups" => "1,5" } }
    let(:metadata) { { "group_ids" => [1, 2] } }
    let(:wrong_metadata) { { "group_ids" => [2, 3] } }

    context "when user is authorized" do
      let!(:authorization) { create(:authorization, user:, name: handler_name, metadata:) }

      it "allows to join a meeting" do
        visit_and_join_meeting

        expect(page).to have_no_content "Authorization required"
        expect(page).to have_no_content "Not authorized"
      end

      it "allows to create a proposal" do
        visit_and_create_proposal
        expect(page).to have_no_content "Not authorized"
        expect(page).to have_no_content "Authorization required"
        expect(page).to have_css ".new_proposal"
      end
    end

    context "when user is authorized with wrong metadata" do
      let!(:authorization) { create(:authorization, user:, name: handler_name, metadata: wrong_metadata) }

      it "does not allow to join a meeting" do
        visit_and_join_meeting
        expect(page).to have_content "Not authorized"
        expect(page).to have_no_button "Submit"
      end

      it "does not allow to create a proposal" do
        visit_and_create_proposal
        expect(page).to have_content "Not authorized"
        expect(page).to have_no_css ".new_proposal"
      end
    end

    context "when user is not authorized" do
      let!(:authorization) { nil }

      it "does not allow to join a meeting" do
        visit_and_join_meeting
        expect(page).to have_content "Authorization required"
        expect(page).to have_no_button "Submit"
      end

      it "does not allow to create a proposal" do
        visit_and_create_proposal
        expect(page).to have_content "Authorization required"
        expect(page).to have_no_css ".new_proposal"
      end
    end
  end

  def visit_and_join_meeting
    page.visit resource_locator(meeting).path
    click_on "Register"
  end

  def visit_and_create_proposal
    page.visit main_component_path(proposals_component)
    click_on "New proposal"
  end
end
