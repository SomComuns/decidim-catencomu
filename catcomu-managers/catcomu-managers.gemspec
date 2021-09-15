$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "managers/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "catcomu-managers"
  spec.version     = Managers::VERSION
  spec.authors     = ["Ivan Vergés"]
  spec.email       = ["ivan@platoniq.net"]
  spec.summary     = "Decidim Awesome Scoped admins Manager."
  spec.description = "Allows extra operations with scoped admins by decidim awesome"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  spec.add_dependency "decidim-core", "~> #{Managers::DECIDIM_VERSION}"
  spec.add_dependency "decidim-admin", "~> #{Managers::DECIDIM_VERSION}"

  spec.add_development_dependency "decidim-dev", "~> #{Managers::DECIDIM_VERSION}"
end
