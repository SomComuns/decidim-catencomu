# frozen_string_literal: true

module Managers
  module Admin
    class AdminEngine < ::Rails::Engine
      isolate_namespace Managers::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :scoped_admins
        root to: "scoped_admins#index"
      end

      initializer "catcomu.admin_menus" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.managers", scope: "decidim.admin", default: "Managers"),
                    managers_admin.root_path,
                    icon_name: "firj",
                    position: 1,
                    active: is_active_link?(managers_admin.root_path, :inclusive),
                    if: defined?(current_user) && current_user.admin?
        end
      end
    end
  end
end
