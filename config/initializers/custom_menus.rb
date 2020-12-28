
Rails.application.config.after_initialize do
 Decidim::MenuRegistry.find(:menu).configurations[0] = Proc.new do |menu|
    menu.item "test #{Decidim::MenuRegistry.find(:menu).configurations.count}",
            decidim.root_path,
            position: 1.1
  end  
end
