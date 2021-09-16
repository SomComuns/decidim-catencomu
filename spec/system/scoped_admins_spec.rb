# frozen_string_literal: true

require "rails_helper"

describe "Scoped admins", type: :system do
  let(:organization) { create(:organization) }

  let(:user) { create(:user, :confirmed, organization: organization) }

  let!(:participatory_process) { create :participatory_process, participatory_process_group: participatory_process_group, organization: organization }
  let!(:another_participatory_process) { create :participatory_process, organization: organization }
  let!(:participatory_process_group) { create :participatory_process_group, organization: organization }
  let!(:another_participatory_process_group) { create :participatory_process_group, organization: organization }
  let!(:config) { create :awesome_config, organization: organization, var: :scoped_admins, value: scoped_admins }
  let(:config_helper) { create :awesome_config, organization: organization, var: :scoped_admin_bar }
  let!(:helper_constraint) { create :config_constraint, awesome_config: config_helper, settings: settings }
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
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "user has admin access" do
    visit decidim_admin.root_path
    expect(page).to have_content("Welcome to the Decidim Admin Panel.")
  end

  it "has access to managers module" do
    visit catcomu_managers_admin.scoped_admins_path

    expect(page).to have_content("Participative processes in this group")
  end

  it "can edit the group" do
    visit catcomu_managers_admin.scoped_admins_path
    click_link "Edit this group"

    expect(page).to have_content("Edit process group")
  end

  it "does not show other processes" do
    visit catcomu_managers_admin.scoped_admins_path

    expect(page).to have_content(participatory_process.title["en"])
    expect(page).not_to have_content(another_participatory_process.title["en"])
  end

  it "can edit the processes" do
    visit catcomu_managers_admin.scoped_admins_path
    click_link href: "/admin/participatory_processes/#{participatory_process.slug}/edit"

    expect(page).to have_content("General Information")
    expect(page).to have_content("Short description")

    fill_in_i18n(
      :participatory_process_title,
      "#participatory_process-title-tabs",
      en: "Edited participatory_process"
    )
    find("*[type=submit]").click
    expect(page).to have_admin_callout("successfully")
  end

  it "cannot change the group of the process" do
    visit catcomu_managers_admin.scoped_admins_path
    click_link href: "/admin/participatory_processes/#{participatory_process.slug}/edit"

    fill_in_i18n(
      :participatory_process_title,
      "#participatory_process-title-tabs",
      en: "Edited participatory_process"
    )
    select another_participatory_process_group.title["en"], from: :participatory_process_participatory_process_group_id
    find("*[type=submit]").click
    expect(page).to have_admin_callout("There was a problem updating this participatory process.")
  end
end
