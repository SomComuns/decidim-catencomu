# frozen_string_literal: true

require "rails_helper"
require "decidim/proposals/test/factories"
require "decidim/meetings/test/factories"

describe "Restrict_actions_by_CiviCRM_groups_verification" do
  include_context "with a component"

  let(:handler_name) { "civicrm_groups" }
  let(:manifest_name) { "proposals" }

  let!(:organization) do
    create(:organization, available_authorizations: [handler_name])
  end

  let!(:user) { create(:user, :confirmed, organization:) }

  let!(:participatory_space) do
    create(:participatory_process, :with_steps, organization:)
  end

  let!(:meeting_address) { "Some address" }
  let!(:latitude) { 40.1234 }
  let!(:longitude) { 2.1234 }

  let!(:meetings_component) do
    create(
      :meeting_component,
      manifest: Decidim.find_component_manifest("meetings"),
      participatory_space:,
      permissions:
    )
  end

  let!(:proposals_component) do
    create(
      :proposal_component,
      :with_creation_enabled,
      manifest: Decidim.find_component_manifest("proposals"),
      participatory_space:,
      permissions:
    )
  end

  let!(:meeting) do
    create(:meeting, :published, component: meetings_component,
                                 registrations_enabled: true, address: meeting_address,
                                 latitude:, longitude:)
  end

  before do
    stub_geocoding(meeting_address, [latitude, longitude])
    stub_geocoding_coordinates([latitude, longitude])

    switch_to_host(organization.host)
    Capybara.app_host = "http://#{organization.host}"
    login_as user, scope: :user
  end

  around do |example|
    I18n.with_locale(:en) { example.run }
  end

  describe "CiviCRM group-based authorization" do
    let(:valid_metadata) { { "group_ids" => [1, 2] } }
    let(:invalid_metadata) { { "group_ids" => [2, 3] } }

    context "when user is authorized with correct group" do
      let(:permissions) do
        {
          create: {
            authorization_handlers: {
              handler_name => { "options" => { "groups" => "1,5" } }
            }
          }
        }
      end
      let!(:authorization) { create(:authorization, user:, name: handler_name, metadata: valid_metadata) }

      before do
        meetings_component.update!(permissions:)
        proposals_component.update!(permissions:)
      end

      it "allows joining a meeting" do
        visit_and_join_meeting
        expect(page).to have_no_content("Authorization required")
        expect(page).to have_no_content("Not authorized")
      end

      it "allows creating a proposal" do
        visit_and_create_proposal
        expect(page).to have_no_content("Authorization required")
        expect(page).to have_no_content("Not authorized")
        expect(page).to have_css(".new_proposal")
      end
    end

    context "when user is authorized with wrong metadata" do
      let!(:authorization) { create(:authorization, user:, name: handler_name, metadata: invalid_metadata) }

      context "when trying to join a meeting" do
        let(:permissions) do
          {
            join: {
              authorization_handlers: {
                handler_name => { "options" => { "groups" => "1,5" } }
              }
            }
          }
        end

        it "does not allow joining a meeting" do
          visit_and_join_meeting
          expect(page).to have_content("Not authorized")
          expect(page).to have_no_button("Submit")
        end
      end

      context "when trying to create a proposal" do
        let(:permissions) do
          {
            create: {
              authorization_handlers: {
                handler_name => { "options" => { "groups" => "1,5" } }
              }
            }
          }
        end

        it "does not allow creating a proposal" do
          visit_and_create_proposal
          expect(page).to have_content("Not authorized")
          expect(page).to have_no_css(".new_proposal")
        end
      end
    end

    context "when user has no authorization" do
      let(:permissions) { nil }
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
    visit resource_locator(meeting).path
    click_on "Register", match: :first
  end

  def visit_and_create_proposal
    visit main_component_path(proposals_component)
    click_on "New proposal", match: :first
  end
end
