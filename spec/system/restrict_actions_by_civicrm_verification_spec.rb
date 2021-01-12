# frozen_string_literal: true

require "rails_helper"

describe "Restrict actions by CiviCRM verification", type: :system do
  let(:organization) { create(:organization) }

  let(:user) { create(:user, :confirmed, organization: organization) }

  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:proposals_component) { create :component, manifest_name: :proposals, participatory_space: participatory_process, permissions: permissions }
  let!(:proposal) { create :proposal, component: proposals_component }

  let(:options) { {} }
  let(:authorization_options) do
    {
      authorization_handlers: {
        handler_name => { "options" => options }
      }
    }
  end

  before do
    organization.available_authorizations = [handler_name]
    organization.save!
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  after do
    expect_no_js_errors
  end

  shared_examples "comment on proposal" do
    let(:permissions) { { comment: authorization_options } }

    shared_examples "cannot comment" do
      it "does not allow to comment" do
        visit_proposal
        within "#comments" do
          expect(page).not_to have_button "Send"

          within ".callout.warning" do
            expect(page).to have_selector "[data-open=authorizationModal]"
          end
        end
      end
    end

    describe "comment on proposal" do
      context "when user is authorized" do
        let!(:authorization) { create(:authorization, user: user, name: handler_name, metadata: metadata) }

        it "allows to comment" do
          visit_proposal
          within "#comments" do
            expect(page).to have_selector "textarea"
            fill_in "Comment", with: "A very thoughtful comment"
            expect(page).to have_button "Send"
          end
        end
      end

      context "when user is authorized with options different than required" do
        let!(:authorization) { create(:authorization, user: user, name: handler_name, metadata: wrong_metadata) }

        it_behaves_like "cannot comment"
      end

      context "when user is not authorized" do
        let!(:authorization) { nil }

        it_behaves_like "cannot comment"
      end
    end
  end

  shared_examples "vote comment on proposal" do
    let(:permissions) { { vote_comment: authorization_options } }

    let!(:comment) { create(:comment, commentable: proposal) }

    shared_examples "cannot vote" do
      it "does not allow to vote", :slow do
        visit_proposal
        within "#comments" do
          page.find(".comment__votes--up").click
          expect(page).to have_selector(".comment__votes--up", text: /0/)
        end
      end
    end

    describe "comment on proposal" do
      context "when user is authorized" do
        let!(:authorization) { create(:authorization, user: user, name: handler_name, metadata: metadata) }

        it "allows to vote", :slow do
          visit_proposal
          within "#comments" do
            page.find(".comment__votes--up").click
            expect(page).to have_selector(".comment__votes--up", text: /1/)
          end
        end
      end

      context "when user is authorized with options different than required" do
        let!(:authorization) { create(:authorization, user: user, name: handler_name, metadata: wrong_metadata) }

        it_behaves_like "cannot vote"
      end

      context "when user is not authorized" do
        let!(:authorization) { nil }

        it_behaves_like "cannot vote"
      end
    end
  end

  describe "group verification" do
    let(:handler_name) { "groups" }
    let(:options) { { "group" => "group_name" } }
    let(:metadata) { { "group" => "group_name" } }
    let(:wrong_metadata) { { "group" => "other_group_name" } }

    it_behaves_like "comment on proposal"
    it_behaves_like "vote comment on proposal"
  end

  describe "role verification" do
    let(:handler_name) { "civicrm" }
    let(:options) { { "role" => "role_name" } }
    let(:metadata) { { "role" => "role_name" } }
    let(:wrong_metadata) { { "role" => "other_role_name" } }

    it_behaves_like "comment on proposal"
    it_behaves_like "vote comment on proposal"
  end

  describe "regional scope verification" do
    let(:handler_name) { "civicrm" }
    let(:options) { { "regional_scope" => "regional_scope_id" } }
    let(:metadata) { { "regional_scope" => "regional_scope_id" } }
    let(:wrong_metadata) { { "regional_scope" => "other_regional_scope_id" } }

    it_behaves_like "comment on proposal"
    it_behaves_like "vote comment on proposal"
  end

  def visit_proposal
    page.visit main_component_path(proposals_component)
    click_link proposal.title["en"]
  end
end
