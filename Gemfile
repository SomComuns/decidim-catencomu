# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.29.3"

gem "decidim", DECIDIM_VERSION

gem "decidim-catcomu_managers", path: "./decidim-module-catcomu_managers"

gem "decidim-alternative_landing", git: "https://github.com/Platoniq/decidim-module-alternative_landing", branch: "main"
gem "decidim-calendar", github: "decidim-ice/decidim-module-calendar", branch: "main"
gem "decidim-civicrm", git: "https://github.com/openpoke/decidim-module-civicrm", branch: "main"
gem "decidim-decidim_awesome", git: "https://github.com/decidim-ice/decidim-module-decidim_awesome", branch: "main"
gem "decidim-navigation_maps", git: "https://github.com/Platoniq/decidim-module-navigation_maps", branch: "main"
gem "decidim-term_customizer", git: "https://github.com/CodiTramuntana/decidim-module-term_customizer", branch: "upgrade/decidim_0.29"

gem "bootsnap", "~> 1.7"
gem "deface"
gem "health_check"
gem "puma", "> 6.2"

group :development, :test do
  gem "byebug", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker", "~> 3.2"
end

group :development do
  gem "letter_opener_web"
  gem "listen"
  gem "web-console"
end

group :production do
  gem "aws-sdk-s3", require: false
  gem "sentry-rails"
  gem "sentry-ruby"
  gem "sidekiq"
  gem "sidekiq-cron"
end
