# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

require "spec_helper"

require "decidim/dev"
require "decidim/core"
require "decidim/verifications"
require "decidim/core/test"
require "letter_opener_web"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

require "support/civicrm_stubs"

Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, ".."))

require "decidim/dev/test/base_spec_helper"

RSpec.configure do |config|
  config.include CivicrmStubs
end
