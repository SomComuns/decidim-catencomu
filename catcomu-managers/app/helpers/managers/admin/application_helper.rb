# frozen_string_literal: true

module Managers
  module Admin
    # Custom helpers, scoped to the admin panel.
    module ApplicationHelper
      def current_user_process_groups
        process_groups_scoped_admins[current_user.id]&.filter_map do |group_id|
          group = Decidim::ParticipatoryProcessGroup.find(group_id)
          next unless group

          group
        end
      end

      def process_groups_scoped_admins
        items = Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: "scoped_admins")&.value
        return [] if items.blank?

        group_admins = {}
        items.each do |key, users|
          constraints = Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: current_organization, var: "scoped_admin_#{key}")&.constraints&.where("settings->>'participatory_space_manifest'='process_groups'")
          next if constraints.blank?

          constraints.pluck(:settings).each do |settings|
            group_id = settings["participatory_space_slug"]
            next if group_id.blank?
            
            users.each do |id|
              (group_admins[id.to_i] ||= []).push(group_id)
            end
          end
        end
        group_admins
      end
    end
  end
end
