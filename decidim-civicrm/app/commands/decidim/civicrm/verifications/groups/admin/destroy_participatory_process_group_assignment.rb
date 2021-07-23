# frozen_string_literal: true

module Decidim
  module Civicrm
    module Verifications
      module Groups
        module Admin
          # This command is executed when the user destroys a ParticipatoryProcessGroupAssignment from the admin
          # panel.
          class DestroyParticipatoryProcessGroupAssignment < Rectify::Command
            # Initializes a DestroyParticipatoryProcessGroupAssignment Command.
            #
            # participatory_process_group_assignment - The current instance of the participatory_process_group_assignment to be destroyed.
            # current_user - the user performing the action
            def initialize(participatory_process_group_assignment, current_user)
              @participatory_process_group_assignment = participatory_process_group_assignment
              @current_user = current_user
            end

            # Destroys the participatory_process_group_assignment.
            #
            # Broadcasts :ok if successful, :invalid otherwise.
            def call
              destroy_participatory_process_group_assignment

              broadcast(:ok)
            end

            private

            attr_reader :participatory_process_group_assignment, :current_user

            def destroy_participatory_process_group_assignment
              participatory_process_group_assignment.destroy!
            end
          end
        end
      end
    end
  end
end
