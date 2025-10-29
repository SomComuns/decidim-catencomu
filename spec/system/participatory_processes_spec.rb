# frozen_string_literal: true

require "rails_helper"

describe "Participatory_processes" do
  let!(:organization) { create(:organization) }
  let!(:global_menu) { create(:content_block, organization:, scope_name: :homepage, manifest_name: :global_menu) }

  let!(:process_group) { create(:participatory_process_group, organization:) }
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
    Decidim::ParticipatoryProcess.scope_groups_mode(nil, nil)
    switch_to_host(organization.host)
  end

  after do
    Decidim::ParticipatoryProcess.scope_groups_mode(nil, nil)
  end

  context "when visiting home page" do
    before do
      visit decidim.root_path
    end

    it "shows the grouped processes menu" do
      within "#home__menu" do
        expect(page).to have_link(text: "Processes", href: "/processes")
      end
      within ".main-footer" do
        expect(page).to have_link(text: "Processes", href: "/processes")
      end
    end

    it "shows the extra configured menu" do
      within "#home__menu" do
        expect(page).to have_link(text: "Global processes", href: "/global_processes")
      end
      within ".main-footer" do
        expect(page).to have_link(text: "Global processes", href: "/global_processes")
      end
    end

    context "and navigating to grouped processes" do
      before do
        within "#home__menu" do
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
    end

    context "when filtering ungrouped participatory processes" do
      let!(:taxonomy) { create(:taxonomy, :with_parent, organization:, name: { en: "A great taxonomy" }) }
      let!(:another_taxonomy) { create(:taxonomy, parent: taxonomy.parent, organization:, name: { en: "Another taxonomy" }) }

      let!(:ungrouped_process_with_taxonomy) do
        create(
          :participatory_process,
          :active,
          taxonomies: [taxonomy],
          organization:
        )
      end

      let!(:ungrouped_process_with_taxonomy_old) do
        create(
          :participatory_process,
          :past,
          taxonomies: [taxonomy],
          organization:
        )
      end

      let!(:ungrouped_process_without_taxonomy) do
        create(
          :participatory_process,
          :active,
          organization:
        )
      end

      let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: taxonomy.parent, participatory_space_manifests:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
      let!(:another_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: another_taxonomy) }
      let(:participatory_space_manifests) { ["participatory_processes"] }

      before do
        within "#home__menu" do
          click_on "Global processes"
        end
      end

      context "and filtering by taxonomy" do
        before do
          within "#panel-dropdown-menu-taxonomy" do
            click_filter_item "A great taxonomy"
            sleep 2
          end
        end

        it "shows only ungrouped processes from that taxonomy" do
          within "#processes-grid" do
            expect(page).to have_content(translated(ungrouped_process_with_taxonomy.title))
            expect(page).to have_no_content(translated(ungrouped_process_without_taxonomy.title))
            expect(page).to have_no_content(grouped_process.title)
          end
        end

        context "and then filtering by time" do
          before do
            within "#panel-dropdown-menu-date" do
              choose "Past"
              sleep 2
            end
          end

          it "shows only past ungrouped processes with that taxonomy" do
            within "#processes-grid" do
              expect(page).to have_content(translated(ungrouped_process_with_taxonomy_old.title))
              expect(page).to have_no_content(translated(ungrouped_process_with_taxonomy.title))
              expect(page).to have_no_content(translated(ungrouped_process_without_taxonomy.title))
              expect(page).to have_no_content(grouped_process.title)
            end
          end

          it "keeps the alternative path" do
            expect(page).to have_current_path(Regexp.new(global_processes_path))
          end
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
