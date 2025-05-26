# frozen_string_literal: true

require "rails_helper"

describe "Free_and_private_login_areas", perform_enqueued: true do
  let(:organization) { create :organization, force_users_to_authenticate_before_access_organization: closed }
  let(:closed) { true }
  let!(:alternative_participatory_process) { create :participatory_process, organization: }
  let!(:participatory_process_group) { create :participatory_process_group, organization: }
  let!(:participatory_process) { create :participatory_process, organization:, participatory_process_group: }
  let(:user) { nil }

  before do
    create :content_block, organization:, scope_name: :homepage, manifest_name: :hero
    create :content_block, organization:, scope_name: :participatory_process_group_homepage, scoped_resource_id: participatory_process_group.id, manifest_name: :title

    login_as user, scope: :user if user

    switch_to_host(organization.host)
  end

  shared_examples "can visit duty free areas" do
    it "allows visiting the homepage" do
      visit decidim.root_path
      expect_homepage
    end

    it "allows visiting processes landing page" do
      visit decidim_participatory_processes.participatory_processes_path
      expect_participatory_processes
    end

    it "allows visiting alternatve processes landing page" do
      visit global_processes_path
      expect_alternative_participatory_processes
    end

    it "allows visiting a process group" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group.id)
      expect_participatory_process_group
    end

    it "forbids visiting a process" do
      visit decidim_participatory_processes.participatory_process_path(participatory_process.slug)
      expect_sign_in
    end
  end

  shared_examples "can visit everything" do
    it "allows visiting the homepage" do
      visit decidim.root_path
      expect_homepage
    end

    it "allows visiting processes landing page" do
      visit decidim_participatory_processes.participatory_processes_path
      expect_participatory_processes
    end

    it "allows visiting alternatve processes landing page" do
      visit global_processes_path
      expect_alternative_participatory_processes
    end

    it "allows visiting a process" do
      visit decidim_participatory_processes.participatory_process_path(participatory_process.slug)
      expect_participatory_process
    end
  end

  context "when organization is closed" do
    it_behaves_like "can visit duty free areas"

    context "and user is logged" do
      let(:user) { create :user, :confirmed, organization: }

      it_behaves_like "can visit everything"
    end
  end

  context "when organization is open" do
    let(:closed) { false }

    it_behaves_like "can visit everything"
  end

  def expect_homepage
    expect(page).to have_content("Welcome to #{translated(organization.name)}")
    expect(current_url).to match("/")
  end

  def expect_sign_in
    expect(page).to have_content("Please, log in with your account before access")
    expect(current_url).to match("/users/sign_in")
  end

  def expect_participatory_processes
    expect(page).to have_content(participatory_process_group.title["en"])
    expect(current_url).to match("/processes")
  end

  def expect_alternative_participatory_processes
    expect(page).to have_content(alternative_participatory_process.title["en"])
    expect(current_url).to match("/global_processes")
  end

  def expect_participatory_process
    expect(page).to have_content(participatory_process.title["en"])
    expect(current_url).to match("/processes/#{participatory_process.slug}")
  end

  def expect_participatory_process_group
    expect(page).to have_content(participatory_process_group.title["en"])
    expect(current_url).to match("/processes_groups/#{participatory_process_group.id}")
  end
end
