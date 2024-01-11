# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.27.5"

gem "decidim", DECIDIM_VERSION
gem "decidim-consultations", DECIDIM_VERSION

gem "decidim-catcomu_managers", path: "./decidim-module-catcomu_managers"

gem "decidim-alternative_landing", git: "https://github.com/Platoniq/decidim-module-alternative_landing"
gem "decidim-civicrm", git: "https://github.com/Platoniq/decidim-module-civicrm"
gem "decidim-decidim_awesome", "~> 0.10.2"
gem "decidim-direct_verifications", git: "https://github.com/Platoniq/decidim-verifications-direct_verifications"
gem "decidim-navigation_maps", git: "https://github.com/Platoniq/decidim-module-navigation_maps"

gem "bootsnap", "~> 1.11.0"
gem "health_check"

gem "puma", ">= 5.0.0"
gem "uglifier", "~> 4.1"

gem "faker", "~> 2.14"
gem "rspec"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "rubocop-faker"

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console"
end

group :production do
  gem "aws-sdk-s3", require: false
  gem "fog-aws" # to remove once images migrated
  gem "sentry-rails"
  gem "sentry-ruby"
  gem "sidekiq", "~> 6.0"
  gem "sidekiq-cron"
end

gem "whenever", require: false
