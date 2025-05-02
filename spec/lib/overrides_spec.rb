# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/decidim/account/show.html.erb" => "f13218e2358a2d611996c2a197c0de25", # blocks email editing
      "/app/views/decidim/devise/omniauth_registrations/new.html.erb" => "49f44efcd7ae6f87c04b309733ff28f6", # blocks email editing
      "/app/views/decidim/devise/sessions/new.html.erb" => "a8fe60cd10c1636822c252d5488a979d", # adds link to civicrm signup
      # concerns
      "/app/controllers/concerns/decidim/force_authentication.rb" => "fb182e6efdbc34a9d2b75aa4df06faa1",
      # helpers
      "/app/helpers/decidim/filters_helper.rb" => "d487fd31753012253aea7aa5fb6acfc3",
      "/app/views/layouts/decidim/header/_main.html.erb" => "69acfdeade5dab8cd73e1d19f37fef2c" # add language chooser to header
    }
  },
  {
    package: "decidim-participatory_processes",
    files: {
      # views
      "/app/views/decidim/participatory_processes/participatory_processes/index.html.erb" => "356fe312dfd6f31607e72f619628f6f1", # processes index page
      "/app/models/decidim/participatory_process.rb" => "6f19ab033d83404a6f314911b7538fbf",
      # cells
      "/app/cells/decidim/participatory_processes/process_filters_cell.rb" => "cd533ebf6e4de40d74ca838eea90341d",
      # routes definition
      "/lib/decidim/participatory_processes/engine.rb" => "768f018c309226defc178b9e58d3173a"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/cells/decidim/meetings/join_meeting_button/show.erb" => "f885f36957b27f20535c8d5b985ecee5"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
