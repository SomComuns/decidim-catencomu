# frozen_string_literal: true
require "digest/md5"

class CivicrmAuthorizationHandler < Decidim::AuthorizationHandler
  include ActionView::Helpers::SanitizeHelper
  include Virtus::Multiparams

  attribute :email, String

  validates :email, format: { with: Devise.email_regexp }, presence: true

  validate :user_valid

  # If you need to store any of the defined attributes in the authorization you
  # can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it's created, and available though authorization.metadata
  def metadata
    super.merge(
      role: response["role"]
    )
  end

  def unique_id
    Digest::MD5.hexdigest(
      "#{email&.downcase}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  private

  def user_valid
    return nil if response.blank?

    errors.add(:document_number, I18n.t("civicrm_authorization_handler.invalid_email", scope: "decidim.authorization_handlers")) unless response.xpath("//existe").text == "SI"
  end

  def response
    return nil if email.blank?

    return @response if defined?(@response)

    response ||= Faraday.post Rails.application.secrets.census_url do |request|
      request.headers["Content-Type"] = "text/xml;charset=UTF-8'"
      request.headers["SOAPAction"] = %w{"http://webtests02.getxo.org/Validar"}
      request.body = request_body
    end

    @response ||= Nokogiri::XML(response.body).remove_namespaces!
  end


  def request_body
    @request_body ||= <<EOS
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Validar xmlns="http://webtests02.getxo.org/">
      <strDNI>#{sanitized_document_number}</strDNI>
      <strLetra>#{sanitized_document_letter}</strLetra>
      <strNacimiento>#{sanitized_date_of_birth}</strNacimiento>
    </Validar>
  </soap:Body>
</soap:Envelope>
EOS
  end
end