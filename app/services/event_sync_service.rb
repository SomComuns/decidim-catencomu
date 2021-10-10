# frozen_string_literal: true

# typical response:
# {
#  "is_error"=>0,
#   "version"=>3,
#   "count"=>1,
#   "id"=>72,
#   "values"=>{
#     "72"=>{
#       "id"=>"72",
#       "title"=>"Assembly: meeting",
#       "summary"=>"",
#       "description"=>"",
#       "event_type_id"=>"",
#       "participant_listing_id"=>"",
#       "is_public"=>"",
#       "start_date"=>"20210928000000",
#       "end_date"=>"",
#       "is_online_registration"=>"",
#       "registration_link_text"=>"",
#       "registration_start_date"=>"",
#       "registration_end_date"=>"",
#       "max_participants"=>"",
#       "event_full_text"=>"",
#       "is_monetary"=>"",
#       "financial_type_id"=>"",
#       "payment_processor"=>"",
#       "is_map"=>"",
#       "is_active"=>"1",
#       "fee_label"=>"",
#       "is_show_location"=>"",
#       "loc_block_id"=>"",
#       "default_role_id"=>"",
#       "intro_text"=>"",
#       "footer_text"=>"",
#       "confirm_title"=>"",
#       "confirm_text"=>"",
#       "confirm_footer_text"=>"",
#       "is_email_confirm"=>"",
#       "confirm_email_text"=>"",
#       "confirm_from_name"=>"",
#       "confirm_from_email"=>"",
#       "cc_confirm"=>"",
#       "bcc_confirm"=>"",
#       "default_fee_id"=>"",
#       "default_discount_fee_id"=>"",
#       "thankyou_title"=>"",
#       "thankyou_text"=>"",
#       "thankyou_footer_text"=>"",
#       "is_pay_later"=>"",
#       "pay_later_text"=>"",
#       "pay_later_receipt"=>"",
#       "is_partial_payment"=>"",
#       "initial_amount_label"=>"",
#       "initial_amount_help_text"=>"",
#       "min_initial_amount"=>"",
#       "is_multiple_registrations"=>"",
#       "max_additional_participants"=>"",
#       "allow_same_participant_emails"=>"",
#       "has_waitlist"=>"",
#       "requires_approval"=>"",
#       "expiration_time"=>"",
#       "allow_selfcancelxfer"=>"",
#       "selfcancelxfer_time"=>"",
#       "waitlist_text"=>"",
#       "approval_req_text"=>"",
#       "is_template"=>"0",
#       "template_title"=>"",
#       "created_id"=>"15476",
#       "created_date"=>"20210930172211",
#       "currency"=>"",
#       "campaign_id"=>"",
#       "is_share"=>"",
#       "is_confirm_enabled"=>"",
#       "parent_event_id"=>"",
#       "slot_label_id"=>"",
#       "dedupe_rule_group_id"=>"",
#       "is_billing_required"=>""
#     }
#   }
# }

class EventSyncService
  def initialize(parser)
    @parser = parser
    @result = {}
  end

  attr_reader :result, :parser

  def publish
    request = Decidim::Civicrm::Api::Request.post(parser.data)
    @result = request.response
    @result["is_error"] == 1 ? nil : @result
  rescue StandardError => e
    @result["exception"] = e.message
    nil
  end
end
