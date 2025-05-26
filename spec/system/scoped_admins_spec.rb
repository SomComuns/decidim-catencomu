# frozen_string_literal: true

require "rails_helper"

describe "Scoped_admins" do
  let(:organization) { create(:organization) }

  let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }

  let!(:participatory_process) { create :participatory_process, participatory_process_group:, organization: }
  let!(:another_participatory_process) { create :participatory_process, organization: }
  let!(:participatory_process_group) { create :participatory_process_group, organization: }
  let!(:another_participatory_process_group) { create :participatory_process_group, organization: }
  let!(:config) { create :awesome_config, organization:, var: :scoped_admins, value: scoped_admins }
  let(:config_helper) { create :awesome_config, organization:, var: :scoped_admin_bar }
  let!(:helper_constraint) { create :config_constraint, awesome_config: config_helper, settings: }
  let(:scoped_admins) do
    {
      "bar" => [user.id.to_s]
    }
  end
  let(:settings) do
    {
      "participatory_space_manifest" => "process_groups",
      "participatory_space_slug" => participatory_process_group.id.to_s
    }
  end

  before do
    # ErrorController is only called when in production mode, so we simulated it
    # otherwise admin redirections do not work
    unless ENV["SHOW_EXCEPTIONS"]
      allow(Rails.application).to \
        receive(:env_config).with(no_args).and_wrap_original do |m, *|
          m.call.merge(
            "action_dispatch.show_exceptions" => true,
            "action_dispatch.show_detailed_exceptions" => false
          )
        end
    end

    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "user has admin access" do
    visit decidim_admin.root_path
    expect(page).to have_content("Dashboard")
  end

  it "has access to managers module" do
    visit decidim_catcomu_managers_admin.scoped_admins_path

    expect(page).to have_content("Participative processes in this group")
  end

  it "can edit the group" do
    visit decidim_catcomu_managers_admin.scoped_admins_path
    click_on "Edit this group"

    expect(page).to have_content("Edit process group")
  end

  it "does not show other processes" do
    visit decidim_catcomu_managers_admin.scoped_admins_path

    expect(page).to have_content(participatory_process.title["en"])
    expect(page).to have_no_content(another_participatory_process.title["en"])
  end

  it "can edit the processes" do
    visit decidim_catcomu_managers_admin.scoped_admins_path
    within "tr", text: translated(participatory_process.title) do
      click_on "Configure"
    end

    expect(page).to have_content("General Information")
    expect(page).to have_content("Short description")

    fill_in_i18n(
      :participatory_process_title,
      "#participatory_process-title-tabs",
      en: "Edited participatory_process"
    )
    click_on "Update"
    expect(page).to have_admin_callout("successfully")
  end

  it "cannot change the group of the process" do
    visit decidim_catcomu_managers_admin.scoped_admins_path
    within "tr", text: translated(participatory_process.title) do
      click_on "Configure"
    end

    fill_in_i18n(
      :participatory_process_title,
      "#participatory_process-title-tabs",
      en: "Edited participatory_process"
    )
    select another_participatory_process_group.title["en"], from: :participatory_process_participatory_process_group_id
    click_on "Update"
    expect(page).to have_admin_callout("There was a problem updating this participatory process.")
  end

  context "when user is admin" do
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    it "can change the group of the process" do
      visit decidim_catcomu_managers_admin.scoped_admins_path
      within "tr", text: translated(participatory_process.title) do
        click_on "Configure"
      end

      fill_in_i18n(
        :participatory_process_title,
        "#participatory_process-title-tabs",
        en: "Edited participatory_process"
      )
      select another_participatory_process_group.title["en"], from: :participatory_process_participatory_process_group_id
      click_on "Update"
      expect(page).to have_admin_callout("Participatory process successfully updated.")
    end
  end

  context "when user is not scoped" do
    let(:scoped_admins) do
      {}
    end

    it "user has no admin access" do
      visit decidim_admin.root_path

      expect(page).to have_content("The page you are looking for cannot be found")
    end

    it "has not actions in managers module" do
      visit decidim_catcomu_managers_admin.scoped_admins_path

      expect(page).to have_content("Sorry, your user is not scoped into a group of processes!")
      expect(page).to have_no_content(participatory_process.title["en"])
      expect(page).to have_no_content(another_participatory_process.title["en"])
    end
  end
end
