# frozen_string_literal: true

module Catcomu
  module Managers
    module Admin
      class AdminEngine < ::Rails::Engine
        isolate_namespace Catcomu::Managers::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resources :scoped_admins do
            post "new_process", on: :collection
          end
          root to: "scoped_admins#index"
        end

        # some overrides
        config.to_prepare do
          Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm.include(Catcomu::Managers::ParticipatoryProcessFormOverride)
        end

        initializer "catcomu.admin_menus" do
          Decidim.menu :admin_menu do |menu|
            menu.item I18n.t("menu.managers", scope: "decidim.admin", default: "Managers"),
                      catcomu_managers_admin.root_path,
                      icon_name: "fork",
                      position: 1,
                      active: is_active_link?(catcomu_managers_admin.root_path, :inclusive),
                      if: defined?(current_user)
          end
        end
      end
    end
  end
end
