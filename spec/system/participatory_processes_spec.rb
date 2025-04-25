# frozen_string_literal: true

require "rails_helper"

describe "Participatory_processes" do
  let!(:organization) { create(:organization) }
  let!(:process_group) { create :participatory_process_group, organization: }
  let!(:ungrouped_process) do
    create(
      :participatory_process,
      :active,
      scope: first_scope,
      area: first_area,
      organization:
    )
  end
  let!(:ungrouped_process_old) do
    create(
      :participatory_process,
      :past,
      scope: second_scope,
      area: second_area,
      organization:
    )
  end
  let!(:grouped_process) do
    create(
      :participatory_process,
      :active,
      scope: first_scope,
      area: first_area,
      organization:,
      participatory_process_group: process_group
    )
  end
  let!(:grouped_process_old) do
    create(
      :participatory_process,
      :past,
      scope: second_scope,
      area: second_area,
      organization:,
      participatory_process_group: process_group
    )
  end
  let!(:first_scope) { create(:scope, organization:) }
  let!(:second_scope) { create(:scope, organization:) }
  let!(:first_area) { create(:area, organization:) }
  let!(:second_area) { create(:area, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when visiting home page" do
    before do
      visit decidim.root_path
    end

    it "shows the grouped processes menu" do
      within ".main-nav" do
        expect(page).to have_link(text: "Processes", href: "/processes")
      end
    end

    it "shows the extra configured menu" do
      within ".main-nav" do
        expect(page).to have_content("Global processes")
        expect(page).to have_link(href: "/global_processes")
      end
    end

    context "and navigating to groupd processes" do
      before do
        within ".main-nav" do
          click_on "Processes"
        end
      end

      it "shows grouped processes" do
        within "#processes-grid" do
          expect(page).to have_content(process_group.title["en"])
          expect(page).to have_no_content(ungrouped_process.title["en"])
        end
      end

      it "has the default path" do
        expect(page).to have_current_path(decidim_participatory_processes.participatory_processes_path)
      end

      it "filter links points to the normal path" do
        page.all(".order-by__tab").each do |el|
          expect(el[:href]).to match(/#{decidim_participatory_processes.participatory_processes_path}/)
        end
      end

      # this filter is never shown in scoped processes
      # it "show grouped processes when filtering" do
      #   within ".order-by__tabs" do
      #     click_on "Past"
      #   end

      #   expect(page).to have_content(grouped_process_old.title["en"])
      #   expect(page).not_to have_content(grouped_process.title["en"])
      #   expect(page).not_to have_content(ungrouped_process.title["en"])
      #   expect(page).not_to have_content(ungrouped_process_old.title["en"])
      # end
    end

    context "and navigating to ungrouped processes" do
      before do
        within ".main-nav" do
          click_on "Global processes"
        end
      end

      it "shows ungrouped processes" do
        within "#processes-grid" do
          expect(page).to have_content(ungrouped_process.title["en"])
          expect(page).to have_no_content(grouped_process.title["en"])
        end
      end

      it "has the alternative path" do
        expect(page).to have_current_path(global_processes_path)
      end

      context "when filtering by time" do
        before do
          within ".order-by__tabs" do
            click_on "Past"
          end
        end

        it "show ungrouped processes when filtering" do
          expect(page).to have_content(ungrouped_process_old.title["en"])
          expect(page).to have_no_content(ungrouped_process.title["en"])
          expect(page).to have_no_content(grouped_process.title["en"])
          expect(page).to have_no_content(grouped_process_old.title["en"])
        end

        it "has the alternative path" do
          expect(page).to have_current_path(Regexp.new(global_processes_path))
        end
      end

      context "when filtering by scope" do
        before do
          within "#participatory-space-filters" do
            click_on "Select a scope"
          end
          within "#data_picker-modal" do
            click_on translated(first_scope.name)
            click_on "Select"
          end
        end

        it "show ungrouped processes when filtering" do
          expect(page).to have_content(ungrouped_process.title["en"])
          expect(page).to have_no_content(ungrouped_process_old.title["en"])
          expect(page).to have_no_content(grouped_process.title["en"])
          expect(page).to have_no_content(grouped_process_old.title["en"])
        end

        it "has the alternative path" do
          expect(page).to have_current_path(Regexp.new(global_processes_path))
        end
      end

      context "when filtering by area" do
        before do
          within "#participatory-space-filters" do
            select "Select an area"
            select translated(first_area.name)
          end
        end

        it "show ungrouped processes when filtering" do
          expect(page).to have_content(ungrouped_process.title["en"])
          expect(page).to have_no_content(ungrouped_process_old.title["en"])
          expect(page).to have_no_content(grouped_process.title["en"])
          expect(page).to have_no_content(grouped_process_old.title["en"])
        end

        it "has the alternative path" do
          expect(page).to have_current_path(Regexp.new(global_processes_path))
        end
      end
    end
  end

  context "when accessing grouped processes with an alternative path" do
    before do
      visit "/global_processes/#{grouped_process.slug}"
    end

    it "redirects to the grouped processes path" do
      expect(page).to have_current_path(decidim_participatory_processes.participatory_process_path(grouped_process.slug))
    end
  end

  context "when accessing ungrouped processes with the grouped processes path" do
    before do
      visit "/processes/#{ungrouped_process.slug}"
    end

    it "redirects to the alternative path" do
      expect(page).to have_current_path(global_process_path(ungrouped_process.slug))
    end
  end
end
