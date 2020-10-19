# frozen_string_literal: true

module CivicrmApi
  class Error < StandardError
    def initialize(detail = nil)
      msg = "There was an error with the CiViCRM API"
      msg += " (#{detail})" if detail.present?
      super(msg)
    end
  end
end
