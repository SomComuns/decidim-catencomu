# frozen_string_literal: true
require "digest/md5"

class CivicrmAuthorizationHandler < Decidim::AuthorizationHandler
  PROVIDER_NAME = "civicrm"

  validate :user_valid

  def metadata
    super.merge(
      user_role: response["roles"]&.first,
      roles: response["roles"],
      region_name: response["region_name"],
      region_type: response["region_type"]
    )
  end

  def unique_id
    Digest::SHA512.hexdigest(
      "#{user_uid}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  private

  def organization
    current_organization || user&.organization
  end

  def user_uid
    user&.identities.find_by(organization: organization, provider: PROVIDER_NAME)&.uid
  end

  def user_valid
    return nil if response.blank?
    if response["error"].present?
      errors.add(:user, response["error"])
      # errors.add(:user, I18n.t("civicrm_handler.error", scope: "decidim.authorization_handlers"))
    end
  end

  def request_params
    {
      entity: "Contact",
      action: "Get",
      api_key: Rails.application.secrets.verifications.dig(:civicrm, :api_key),
      key: Rails.application.secrets.verifications.dig(:civicrm, :secret),
      json: true,
      contact_id: user_uid
  end

  def response
    return nil if user_uid.blank?

    return @response if defined?(@response)

    response ||= Faraday.post Rails.application.secrets.verifications.dig(:civicrm, :url) do |request|
      request.params = request_params
      request.headers["Content-Type"] = "application/json"
      request.body = request_body
    end

    @response ||= JSON.parse(response.body).to_h
  end

  def request_body
    @request_body ||= { uid: user_uid }.to_json
  end
end