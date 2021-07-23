# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        module Admin
          # This command is executed when the user creates a new ParticipatoryProcessGroupAssignment from the admin
          # panel.
          class CreateParticipatoryProcessGroupAssignment < Rectify::Command
            # Initializes an CreateParticipatoryProcessGroupAssignment Command.
            #
            # form - The form from which to get the data.
            def initialize(form)
              @form = form
            end

            # Creates the participatory_process_group_assignment if valid.
            #
            # Broadcasts :ok if successful, :invalid otherwise.
            def call
              return broadcast(:invalid) if form.invalid?

              return broadcast(:ok) if create_participatory_process_group_assignment

              broadcast(:invalid)
            end

            private

            attr_reader :form

            def create_participatory_process_group_assignment
              Decidim::Civicrm::ParticipatoryProcessGroupAssignment.create!(
                organization: current_organization,
                civicrm_group_id: form.civicrm_group_id,
                decidim_participatory_process_id: form.decidim_participatory_process_id
              )
            end
          end
        end
      end
    end
  end
end
