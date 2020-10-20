# frozen_string_literal: true

module Decidim
  module Civicrm
    module Api
      class Error < StandardError
        def initialize(detail = nil)
          msg = "There was an error with the CiViCRM API"
          msg += " (#{detail})" if detail.present?
          super(msg)
        end
      end
    end
  end
end
