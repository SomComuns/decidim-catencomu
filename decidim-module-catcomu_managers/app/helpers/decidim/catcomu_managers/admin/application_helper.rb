# frozen_string_literal: true

module Decidim
  module CatcomuManagers
    module Admin
      # Custom helpers, scoped to the admin panel.
      module ApplicationHelper
        def superadmin?
          current_user.attributes["admin"]
        end

        def user_process_admin?(user, process)
          process.user_roles("admin")&.pluck(:decidim_user_id)&.include?(user.id)
        end

        def current_user_process_groups
          return Decidim::ParticipatoryProcessGroup.where(organization: current_organization) if superadmin?

          process_groups_scoped_admins[current_user.id]&.filter_map do |group_id|
            group = Decidim::ParticipatoryProcessGroup.find(group_id)
            next unless group

            group
          end
        end

        def process_groups_scoped_admins
          group_admins = {}
          items = awesome_config_var("scoped_admins")&.value || []

          items.each do |key, users|
            groups = groups_for_constraint_key(key)
            next if groups.blank?

            users.each do |id|
              group_admins[id.to_i] ||= []
              group_admins[id.to_i].concat(groups)
            end
          end
          group_admins
        end

        def groups_for_constraint_key(key)
          constraints = awesome_config_var("scoped_admin_#{key}")&.constraints&.where("settings->>'participatory_space_manifest'='process_groups'")
          constraints&.filter_map do |constraint|
            constraint.settings["participatory_space_slug"].presence
          end
        end

        def awesome_config_var(var)
          Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: var)
        end
      end
    end
  end
end
