# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessOverride
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :scoped_groups_mode, :scoped_groups_namespace

        def scope_groups_mode(mode, namespace)
          self.scoped_groups_mode = mode
          self.scoped_groups_namespace = namespace
        end

        # control the default scope for querying participatory processes in ActiveRecord
        def default_scope
          case scoped_groups_mode
          when :exclude
            where.not(decidim_participatory_process_group_id: nil)
          when :include
            where(decidim_participatory_process_group_id: nil)
          end
        end
      end
    end
  end
end
