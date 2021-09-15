# frozen_string_literal: true

module Managers
  module Admin
    class AdminEngine < ::Rails::Engine
      isolate_namespace Managers::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :scoped_admins do
          post 'new_process', on: :collection
        end
        root to: "scoped_admins#index"
      end

      initializer "catcomu.admin_menus" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.managers", scope: "decidim.admin", default: "Managers"),
                    managers_admin.root_path,
                    icon_name: "fork",
                    position: 1,
                    active: is_active_link?(managers_admin.root_path, :inclusive),
                    if: defined?(current_user)
        end
      end
    end
  end
end
