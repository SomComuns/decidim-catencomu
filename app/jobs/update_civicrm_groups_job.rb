# frozen_string_literal: true

class UpdateCivicrmGroupsJob < ApplicationJob
  queue_as :default

  def perform(organization_id)
    ParticipatoryProcessGroupAssignment.where(decidim_organization_id: organization_id).each do |group_process|
      update_group(group_process)
    end
  end

  private

  def add_private_participants(organization_id, civicrm_group_id, decidim_user_ids)
    private_process = ParticipatoryProcessGroupAssignment.find_by(
      decidim_organization_id: organization_id,
      civicrm_group_id: civicrm_group_id
    )&.participatory_process

    return if private_process.blank?

    Decidim::User.where(id: decidim_user_ids).pluck(:name, :email).each do |user|
      user_name, user_email = user
      add_private_participant(private_process, user_name, user_email)
    end
  end

  def add_private_participant(private_process, user_name, user_email)
    private_user_form = Decidim::Admin::ParticipatorySpacePrivateUserForm.from_params({ name: user_name, email: user_email }, privatable_to: private_process)

    Decidim::Admin::CreateParticipatorySpacePrivateUser.call(private_user_form, nil, private_process)
  end

  def remove_private_participants(organization_id, civicrm_group_id, decidim_user_ids)
    private_process = ParticipatoryProcessGroupAssignment.find_by(
      decidim_organization_id: organization_id,
      civicrm_group_id: civicrm_group_id
    )&.participatory_process

    return if private_process.blank?

    Decidim::ParticipatorySpacePrivateUser.where(decidim_user_id: decidim_user_ids, privatable_to: private_process).find_each do |participatory_space_private_user|
      Decidim::Admin::DestroyParticipatorySpacePrivateUser.call(participatory_space_private_user, nil)
    end
  end

  def update_group(group_process)
    civicrm_users = Api::Request.new.users_in_group(group_process.civicrm_group_id)
    civicrm_uids = civicrm_users.map { |civicrm_user| civicrm_user.dig("api.Usercat.get", "values", 0, "id") }
    decidim_user_ids = Decidim::Identity.where(decidim_organization_id: group_process.decidim_organization_id, provider: "civicrm", uid: civicrm_uids).pluck(:decidim_user_id)

    remove_outdated_users(group_process.decidim_organization_id, group_process.civicrm_group_id, decidim_user_ids)
    add_new_users(group_process.decidim_organization_id, group_process.civicrm_group_id, decidim_user_ids)
  end

  def remove_outdated_users(organization_id, civicrm_group_id, decidim_user_ids)
    users_to_remove_from_group = UserGroupAssignment.where(civicrm_group_id: civicrm_group_id).where.not(decidim_user_id: decidim_user_ids)

    Rails.logger.info "UpdateCivicrmGroupsJob: " \
                      "Removing from Decidim::Civicrm::UserGroupAssignment ##{civicrm_group_id} " \
                      "#{users_to_remove_from_group.count} users with id: #{users_to_remove_from_group.pluck(:decidim_user_id)}"

    remove_private_participants(organization_id, civicrm_group_id, users_to_remove_from_group.pluck(:decidim_user_id))

    users_to_remove_from_group.destroy_all
  end

  def add_new_users(organization_id, civicrm_group_id, decidim_user_ids)
    users_already_in_group = UserGroupAssignment.where(civicrm_group_id: civicrm_group_id, decidim_user_id: decidim_user_ids)

    new_users_added_to_group = UserGroupAssignment.create!(
      (decidim_user_ids - users_already_in_group.pluck(:decidim_user_id)).map do |decidim_user_id|
        {
          civicrm_group_id: civicrm_group_id,
          decidim_user_id: decidim_user_id,
          data: { uid: Decidim::Identity.find_by(decidim_user_id: decidim_user_id).uid }
        }
      end
    )

    add_private_participants(organization_id, civicrm_group_id, new_users_added_to_group.pluck(:decidim_user_id))

    Rails.logger.info "UpdateCivicrmGroupsJob: " \
                      "Added to Decidim::Civicrm::UserGroupAssignment ##{civicrm_group_id} " \
                      "#{new_users_added_to_group.count} users with id: #{new_users_added_to_group.pluck(:decidim_user_id)}"
  end
end
