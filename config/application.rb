# frozen_string_literal: true

require_relative "boot"

require "decidim/rails"

# Add the frameworks used by your app that are not loaded by Decidim.
require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"
require_relative "../app/middleware/participatory_processes_scoper"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Catencomu
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # this middleware will detect by the URL if all calls to Assembly need to skip (or include) certain types
    # this is done here to be sure it is run after the Decidim gem own initializers
    initializer :scopers do |app|
      # this middleware will detect by the URL if all calls to Assembly need to skip (or include) certain types
      # this is done here to be sure it is run after the Decidim gem own initializers
      app.config.middleware.insert_after Decidim::Middleware::StripXForwardedHost, ParticipatoryProcessesScoper
      # this avoid to trap the error trace when debugging errors
      Rails.backtrace_cleaner.add_silencer { |line| line =~ %r{app/middleware} }
    end
  end
end
