# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { git: "https://github.com/Platoniq/decidim", branch: "temp/0.24" }.freeze

gem "decidim", DECIDIM_VERSION
gem "decidim-alternative_landing", git: "https://github.com/Platoniq/decidim-module-alternative_landing", branch: "main"
gem "decidim-consultations", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-civicrm", path: "./decidim-civicrm"

gem "decidim-decidim_awesome", git: "https://github.com/Platoniq/decidim-module-decidim_awesome"
gem "decidim-direct_verifications", git: "https://github.com/Platoniq/decidim-verifications-direct_verifications"
gem "decidim-navigation_maps", "~> 1.2.0"

gem "bootsnap", "~> 1.4"
gem "health_check"
gem "sentry-rails"
gem "sentry-ruby"

gem "puma", ">= 5.0.0"
gem "uglifier", "~> 4.1"

gem "faker", "~> 2.14"
gem "rspec"
gem "rubocop-faker"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :production do
  gem "fog-aws"
  gem "sidekiq", "~> 6.0"
  gem "sidekiq-cron"
end

gem "whenever", require: false