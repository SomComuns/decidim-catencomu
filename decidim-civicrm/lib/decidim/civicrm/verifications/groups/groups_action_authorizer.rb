# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        class GroupsActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
          def authorize
            return [:missing, { action: :authorize }] if authorization.blank?

            status_code = :unauthorized

            return [status_code, { fields: { "groups": "..." } }] if groups.blank?
            return [:ok, {}] if belongs_to_group?

            [status_code, {}]
          end

          private

          def groups
            authorization.metadata["groups"]
          end

          def belongs_to_group?
            groups.include? options["group"]
          end

          def manifest
            @manifest ||= Decidim::Verifications.find_workflow_manifest(authorization&.name)
          end
        end
      end
    end
  end
end
