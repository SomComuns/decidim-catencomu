# frozen_string_literal: true

module Decidim
  module CatcomuManagers
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::CatcomuManagers::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :scoped_admins do
          post "new_process", on: :collection
          post "set_sync_groups", on: :collection
        end
        root to: "scoped_admins#index"
      end

      # some overrides
      config.to_prepare do
        Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm.include(Decidim::CatcomuManagers::Admin::ParticipatoryProcessFormOverride)
        # Decidim::Admin::ApplicationController.include(Decidim::CatcomuManagers::Admin::NeedsMenuSnippets)
      end

      initializer "decidim_catcomu_managers.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :catcomu_managers,
                        I18n.t("menu.managers", scope: "decidim.admin", default: "Managers"),
                        decidim_catcomu_managers_admin.root_path,
                        icon_name: "fork",
                        position: 1,
                        active: is_active_link?(decidim_catcomu_managers_admin.root_path, :inclusive),
                        if: defined?(current_user)
        end
      end

      initializer "decidim_catcomu_managers.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
