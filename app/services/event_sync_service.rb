# frozen_string_literal: true

class EventSyncService
  def initialize(parser)
    @parser = parser
    @result = {}
  end
  
  attr_reader :result, :parser

  def publish
    @result = Decidim::Civicrm::Api::Request.new.post(parser.data)
  rescue StandardError => e
    @result["exception"] = e.message
    nil
  end
end