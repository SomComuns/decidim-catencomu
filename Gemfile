# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "openpoke/decidim", branch: "0.31-backports" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-elections", DECIDIM_VERSION
gem "decidim-templates", DECIDIM_VERSION

gem "decidim-catcomu_managers", path: "./decidim-module-catcomu_managers"

# gem "decidim-alternative_landing", git: "https://github.com/Platoniq/decidim-module-alternative_landing", branch: "release/0.29-stable"
# gem "decidim-calendar", github: "decidim-ice/decidim-module-calendar", branch: "main"
gem "decidim-civicrm", git: "https://github.com/openpoke/decidim-module-civicrm", branch: "main"
gem "decidim-decidim_awesome", git: "https://github.com/decidim-ice/decidim-module-decidim_awesome", branch: "main"
# gem "decidim-navigation_maps", git: "https://github.com/Platoniq/decidim-module-navigation_maps", branch: "main"
gem "decidim-pokecode", github: "openpoke/decidim-module-pokecode", branch: "main"
gem "decidim-term_customizer", git: "https://github.com/openpoke/decidim-module-term_customizer", branch: "main"

gem "bootsnap", "~> 1.7"
gem "puma", "> 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "brakeman", "~> 6.1"
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web"
  gem "listen"
  gem "web-console"
end
