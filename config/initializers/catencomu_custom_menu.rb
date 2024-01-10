# frozen_string_literal: true

Rails.application.config.after_initialize do
  Decidim::MenuRegistry.find(:menu).configurations[0] = proc do |menu|
    menu.add_item :catencomu_home,
                  I18n.t("menu.home", scope: "decidim"),
                  Rails.application.secrets.home_url || decidim.root_path,
                  position: 1
  end
end
