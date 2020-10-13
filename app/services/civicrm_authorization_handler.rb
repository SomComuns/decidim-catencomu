# frozen_string_literal: true
require "digest/md5"

class CivicrmAuthorizationHandler < Decidim::AuthorizationHandler
  PROVIDER_NAME = "civicrm"

  validate :user_valid

  def metadata
    super.merge(
      address: response[:address],
      contact_id: response[:contact_id],
      user_role: response[:user_role],
      roles: response[:roles]
    )
  end

  def unique_id
    Digest::SHA512.hexdigest(
      "#{uid}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  private

  def organization
    current_organization || user&.organization
  end

  def uid
    user&.identities.find_by(organization: organization, provider: PROVIDER_NAME)&.uid
  end

  def user_valid
    return nil if response.blank?
    if response["error"].present?
      errors.add(:user, response["error"])
      # errors.add(:user, I18n.t("civicrm_handler.error", scope: "decidim.authorization_handlers"))
    end
  end

  def response
    return nil if uid.blank?

    return @response if defined?(@response)

    json = CivicrmApi::Request.new.get_user(uid)
    @response ||= CivicrmApi::Models::User.from_contact(json, with_address: true)
  end
end