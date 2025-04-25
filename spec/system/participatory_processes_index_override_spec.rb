# frozen_string_literal: true

require "rails_helper"
require "decidim/navigation_maps/test/factories"

describe "Participatory_processes_index_override" do
  let!(:organization) { create(:organization) }
  let!(:process_group) { create :participatory_process_group, organization: }
  let!(:ungrouped_process) do
    create(
      :participatory_process,
      :active,
      organization:
    )
  end
  let!(:grouped_process) do
    create(
      :participatory_process,
      :active,
      organization:,
      participatory_process_group: process_group
    )
  end

  let!(:navigation_map) { create(:content_block, manifest_name: :navigation_map, scope_name: :homepage, organization:, published_at: nil) }
  let!(:blueprint) { create(:blueprint, organization:, content_block: navigation_map) }

  before do
    switch_to_host(organization.host)
  end

  context "when visiting the processes index page" do
    before do
      visit "/#{ParticipatoryProcessesScoper::DEFAULT_NAMESPACE}"
    end

    it "shows the custom title and description" do
      within "#processes-description" do
        within ".section-heading" do
          expect(page).to have_content(I18n.t("catencomu.processes.title").upcase)
        end
        within ".description" do
          expect(page).to have_content(I18n.t("catencomu.processes.description"))
        end
      end
    end

    it "shows the navigation map" do
      within "#ambits-territorials" do
        expect(page).to have_css(".navigation_maps")
        expect(page).to have_css("#map0")
      end
    end
  end

  context "when visiting the alternative processes index page" do
    before do
      visit "/#{ParticipatoryProcessesScoper::ALTERNATIVE_NAMESPACE}"
    end

    it "doesn't show the custom title and description" do
      expect(page).to have_no_content(I18n.t("catencomu.processes.title"))
      expect(page).to have_no_content(I18n.t("catencomu.processes.description"))
      expect(page).to have_no_css("#processes-description")
    end

    it "doesn't show the navigation map" do
      expect(page).to have_no_css("#ambits-territorials")
      expect(page).to have_no_css(".navigation_maps")
      expect(page).to have_no_css("#map0")
    end
  end
end
