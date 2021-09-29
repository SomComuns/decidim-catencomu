# frozen_string_literal: true

# Subscribe to event and publicate results
Decidim::EventsManager.subscribe(/^decidim\.events\./) do |event_name, data|
  meeting = case event_name
            when "decidim.events.meetings.meeting_created"
              data
  end
  byebug
  # TODO: save meeting in civi
  # POST http://***/profiles/civigo_master/modules/contrib/civicrm/extern/rest.php

  # entity = Participant
  # action = create
  # json = {"event_id":<EventID>,"contact_id":<ContactID>}
  # api_key = <FIXME_USER_KEY>
  # key = <FIXME_SITE_KEY>

  # if parser
  #   unless parser.valid?
  #     Rails.logger.error "Not publishing event ##{data[:resource].id} [#{event_name}] to Weblyzard API: #{parser.errors.values}"
  #     break
  #   end

  #   service = Indices::WeblyzardService.new(parser)
  #   if service.publish
  #     Rails.logger.info "Published event ##{data[:resource].id} [#{event_name}] to Weblyzard API with UID #{service.result["_id"]}"
  #   else
  #     Rails.logger.error "Error publishing event ##{data[:resource].id} [#{event_name}] to Weblyzard API #{service.result}"
  #   end
  # end
end
