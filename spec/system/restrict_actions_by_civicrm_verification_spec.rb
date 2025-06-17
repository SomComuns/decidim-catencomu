# frozen_string_literal: true

require "rails_helper"

describe "Restrict_actions_y_CiviCRM_verification" do
  let(:organization) { create(:organization) }

  let(:user) { create(:user, :confirmed, organization:) }

  let(:participatory_process) { create :participatory_process, organization: }
  let(:proposals_component) { create :component, manifest_name: :proposals, participatory_space: participatory_process, permissions: }
  let!(:proposal) { create :proposal, component: proposals_component }

  let(:options) { {} }
  let(:permissions) { { comment: authorization_options } }
  let(:authorization_options) do
    {
      authorization_handlers: {
        handler_name => { "options" => options }
      }
    }
  end

  before do
    Decidim::ParticipatoryProcess.scope_groups_mode(nil, nil)
    organization.available_authorizations = [handler_name]
    organization.save!
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  after do
    Decidim::ParticipatoryProcess.scope_groups_mode(nil, nil)
    expect_no_js_errors
  end

  shared_examples "can comment" do
    it "allows to comment" do
      visit_proposal
      within "#comments" do
        expect(page).to have_css "textarea"
        fill_in "Comment", with: "A very thoughtful comment"
        expect(page).to have_button "Publish comment"
      end
    end
  end

  shared_examples "cannot comment" do
    it "does not allow to comment" do
      visit_proposal
      within "#comments" do
        expect(page).to have_no_button "Send"

        within ".flash.warning" do
          expect(page).to have_css "[data-dialog-open=authorizationModal]"
        end
      end
    end
  end

  shared_examples "comment on proposal" do
    describe "comment on proposal" do
      context "when user is authorized" do
        let!(:authorization) { create(:authorization, user:, name: handler_name, metadata:) }

        it_behaves_like "can comment"
      end

      context "when user is authorized with options different than required" do
        let!(:authorization) { create(:authorization, user:, name: handler_name, metadata: wrong_metadata) }

        it_behaves_like "cannot comment"
      end

      context "when user is not authorized" do
        let!(:authorization) { nil }

        it_behaves_like "cannot comment"
      end
    end
  end

  describe "civicrm verification" do
    let(:handler_name) { "civicrm" }

    it_behaves_like "cannot comment"

    context "when user is authorized" do
      let!(:authorization) { create(:authorization, user:, name: handler_name) }

      it_behaves_like "can comment"
    end
  end

  describe "civicrm_groups verification" do
    let(:handler_name) { "civicrm_groups" }
    let(:options) { { "groups" => "1,5,9" } }
    let(:metadata) { { "group_ids" => [5, 9] } }
    let(:wrong_metadata) { { "group_ids" => [3, 4] } }

    it_behaves_like "comment on proposal"
  end

  # describe "role verification" do
  #   let(:handler_name) { "civicrm" }
  #   let(:options) { { "role" => "role_name" } }
  #   let(:metadata) { { "role" => "role_name" } }
  #   let(:wrong_metadata) { { "role" => "other_role_name" } }

  #   it_behaves_like "comment on proposal"
  # end

  def visit_proposal
    page.visit main_component_path(proposals_component)
    click_on proposal.title["en"]
  end
end
