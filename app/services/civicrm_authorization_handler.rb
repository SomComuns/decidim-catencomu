# frozen_string_literal: true

require "digest/md5"

class CivicrmAuthorizationHandler < Decidim::AuthorizationHandler
  PROVIDER_NAME = "civicrm"

  validate :user_valid

  def metadata
    super.merge(
      contact_id: response[:contact_id],
      role: response[:role],
      address: response[:address]
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
    user.identities.find_by(organization: organization, provider: PROVIDER_NAME).uid
  end

  def user_valid
    return false if response.blank?
    return true if response["is_error"].blank?

    error_msg = response["error_message"]
    error_code = response["error_code"]

    if error_code.present?
      errors.add(:user, I18n.t("civicrm_authorization_handler.error_codes.#{error_code}", scope: "decidim.authorization_handlers"))
    else
      errors.add(:user, error_msg)
      errors.add(:user, I18n.t("civicrm_authorization_handler.error", scope: "decidim.authorization_handlers"))
    end
  end

  def response
    return nil if uid.blank?

    return @response if defined?(@response)

    @json = CivicrmApi::Request.new.get_user(uid)
    @response = CivicrmApi::Models::User.from_contact(@json, with_address: true)
  end
end
