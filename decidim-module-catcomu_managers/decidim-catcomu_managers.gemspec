# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/catcomu_managers/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-catcomu_managers"
  spec.version = Decidim::CatcomuManagers::VERSION
  spec.authors = ["Ivan Vergés"]
  spec.email = ["ivan@platoniq.net"]
  spec.summary = "Decidim Awesome Scoped admins Manager."
  spec.description = "Allows extra operations with scoped admins by decidim awesome"
  spec.license = "AGPL-3.0"
  spec.required_ruby_version = ">= 2.7"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  spec.add_dependency "decidim-admin", "~> #{Decidim::CatcomuManagers::DECIDIM_VERSION}"
  spec.add_dependency "decidim-core", "~> #{Decidim::CatcomuManagers::DECIDIM_VERSION}"

  spec.add_development_dependency "decidim-dev", "~> #{Decidim::CatcomuManagers::DECIDIM_VERSION}"
end
