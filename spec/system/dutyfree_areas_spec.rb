# frozen_string_literal: true

require "rails_helper"

describe "Free and private login areas", type: :system, perform_enqueued: true do
  let(:organization) { create :organization, force_users_to_authenticate_before_access_organization: closed }
  let(:closed) { true }
  let!(:participatory_process) { create :participatory_process, organization: organization }
  let!(:participatory_process_group) { create :participatory_process_group, :with_participatory_processes, organization: organization }
  let!(:consultation) { create :consultation, :published, organization: organization }
  let(:user) { nil }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :hero
    create :content_block, organization: organization, scope_name: :participatory_process_group_homepage, scoped_resource_id: participatory_process_group.id, manifest_name: :title

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

    it "allows visiting a process group" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group.id)
      expect_participatory_process_group
    end

    it "forbids visiting a process" do
      visit decidim_participatory_processes.participatory_process_path(participatory_process.slug)
      expect_sign_in
    end

    it "forbids visiting consultations" do
      visit decidim_consultations.consultations_path
      expect_sign_in
    end

    it "forbids visiting a consultation" do
      visit decidim_consultations.consultation_path(consultation.slug)
      expect_sign_in
    end
  end

  shared_examples "can visit everything" do
    it "allows visiting the homepage" do
      visit decidim.root_path
      expect_homepage
    end

    it "allows visiting processes groups" do
      visit decidim_participatory_processes.participatory_processes_path
      expect_participatory_processes
    end

    it "allows visiting a process" do
      visit decidim_participatory_processes.participatory_process_path(participatory_process.slug)
      expect_participatory_process
    end

    it "allows visiting a consultation" do
      visit decidim_consultations.consultations_path
      expect_consultations
    end
  end

  context "when organization is closed" do
    it_behaves_like "can visit duty free areas"

    context "and user is logged" do
      let(:user) { create :user, :confirmed, organization: organization }

      it_behaves_like "can visit everything"
    end
  end

  context "when organization is open" do
    let(:closed) { false }

    it_behaves_like "can visit everything"
  end

  def expect_homepage
    expect(page).to have_content("Welcome to #{organization.name}")
    expect(current_url).to match("/")
  end

  def expect_sign_in
    expect(page).to have_content("Please, login with your account before access")
    expect(current_url).to match("/users/sign_in")
  end

  def expect_participatory_processes
    expect(page).to have_content(participatory_process.title["en"])
    expect(current_url).to match("/processes")
  end

  def expect_participatory_process
    expect(page).to have_content(participatory_process.title["en"])
    expect(current_url).to match("/processes/#{participatory_process.slug}")
  end

  def expect_participatory_process_group
    expect(page).to have_content(participatory_process_group.title["en"])
    expect(current_url).to match("/processes_groups/#{participatory_process_group.id}")
  end

  def expect_consultations
    expect(page).to have_content(consultation.title["en"])
    expect(current_url).to match("/consultations")
  end
end
