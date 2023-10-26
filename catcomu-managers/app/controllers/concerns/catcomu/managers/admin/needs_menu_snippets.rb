# frozen_string_literal: true

require "active_support/concern"

# This concern hides some menu items via css as theres no elegant way to do it via Menu registry in Decidim 0.24 (this changes in 0.25)
module Catcomu
  module Managers
    module Admin
      module NeedsMenuSnippets
        extend ActiveSupport::Concern

        included do
          helper_method :snippets
        end

        def snippets
          return @snippets if @snippets

          @snippets = Decidim::Snippets.new
          return @snippets if current_user && current_user.attributes["admin"]

          @snippets.add(:managers_menu, ActionController::Base.helpers.stylesheet_pack_tag("decidim_admin_catcomu_managers_menu_overrides"))

          managers_menu_spaces.each do |space, visible|
            @snippets.add(:managers_menu, "<style>.main-nav li > a[href^=\"/admin/#{space}\"] {display: #{visible ? "block" : "none"}}</style>")
          end
          @snippets.add(:head, @snippets.for(:managers_menu))

          @snippets
        end

        def managers_menu_spaces
          return @managers_menu_spaces if @managers_menu_spaces

          # if private admin of the space, show the menu
          @managers_menu_spaces = Decidim.participatory_space_manifests.map do |manifest|
            [manifest.name.to_s, "#{manifest.model_class_name}UserRole".safe_constantize&.exists?(user: current_user)]
          end.to_h
          # add awesome scoped parts too
          awesome_scoped_admins.each do |key, user_ids|
            next unless user_ids.include?(current_user.id.to_s)

            awesome_settings_for(key).each do |constraint|
              manifest = constraint["participatory_space_manifest"]
              manifest = "participatory_processes" if manifest == "process_groups"
              @managers_menu_spaces[manifest] = true
            end
          end

          @managers_menu_spaces
        end

        def awesome_scoped_admins
          @awesome_scoped_admins ||= Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: "scoped_admins")&.value || []
        end

        def awesome_settings_for(key)
          Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: "scoped_admin_#{key}").constraints.pluck(:settings)
        end
      end
    end
  end
end
