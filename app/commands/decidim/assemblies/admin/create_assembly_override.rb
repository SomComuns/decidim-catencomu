# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      module CreateAssemblyOverride
        extend ActiveSupport::Concern

        included do
          def link_participatory_processes(assembly)
            assembly.link_participatory_space_resources(participatory_processes(assembly), "included_participatory_processes")
            send_notification
          end

          def send_notification
            Decidim::EventsManager.publish(
              event: "decidim.events.assemblies.assembly_created",
              event_class: Decidim::Events::SimpleEvent,
              resource: assembly
            )
          end
        end
      end
    end
  end
end
