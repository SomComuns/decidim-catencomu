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
        Decidim::User.include(Decidim::CatcomuManagers::UserOverride)
      end

      initializer "decidim_catcomu_managers.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :catcomu_managers,
                        I18n.t("menu.managers", scope: "decidim.admin", default: "Managers"),
                        decidim_catcomu_managers_admin.root_path,
                        icon_name: "admin-line",
                        position: 1,
                        active: is_active_link?(decidim_catcomu_managers_admin.root_path, :inclusive),
                        if: defined?(current_user)

          next if current_user && current_user.attributes["admin"]

          menu.remove_item(:dashboard)
          menu.remove_item(:moderations)
          menu.remove_item(:static_pages)
          menu.remove_item(:impersonatable_users)
          menu.remove_item(:newsletters)
          menu.remove_item(:edit_organization)
          menu.remove_item(:logs)

          managers_menu_spaces = Decidim.participatory_space_manifests.to_h do |manifest|
            [manifest.name.to_s, "#{manifest.model_class_name}UserRole".safe_constantize&.exists?(user: current_user)]
          end

          # add awesome scoped parts too
          (Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: "scoped_admins")&.value || []).each do |key, user_ids|
            next unless user_ids.include?(current_user.id.to_s)

            Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: "scoped_admin_#{key}").constraints.pluck(:settings).each do |constraint|
              manifest = constraint["participatory_space_manifest"]
              manifest = "participatory_processes" if manifest == "process_groups"
              managers_menu_spaces[manifest] = true
            end
          end

          managers_menu_spaces.each do |space, visible|
            menu.remove_item(space.to_sym) unless visible
          end
        end
      end

      initializer "decidim_catcomu_managers.webpacker.assets_path" do
        Decidim.icons.register(name: "admin-line", icon: "admin-line", category: "system", description: "", engine: :core)
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
