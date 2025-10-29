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
      "/app/views/decidim/devise/sessions/new.html.erb" => "da0d18178c8dcead2774956e989527c5", # adds link to civicrm signup
      # concerns
      "/app/controllers/concerns/decidim/force_authentication.rb" => "fb182e6efdbc34a9d2b75aa4df06faa1",
      # helpers
      "/app/helpers/decidim/filters_helper.rb" => "7974c1cfd660a97c19ce5805e07af3d2",
      "/app/views/layouts/decidim/header/_main.html.erb" => "2cda0f82a0ac644c1ba89f84d5c60b97", # add language chooser to header
      "/app/views/layouts/decidim/footer/_main.html.erb" => "2d3ecb9824c197951ef8fd7a77bed7d0" # add logo to footer
    }
  },
  {
    package: "decidim-participatory_processes",
    files: {
      # views
      "/app/views/decidim/participatory_processes/participatory_processes/index.html.erb" => "8ef7c51e040a5848519d64eba67146c7", # processes index page
      "/app/models/decidim/participatory_process.rb" => "eb5c7945d1090f1bda8999ce37b5ecc2",
      # cells
      "/app/cells/decidim/participatory_processes/process_filters_cell.rb" => "a088dc80cdc36ff9cb0e8164939f47a8",
      # routes definition
      "/lib/decidim/participatory_processes/engine.rb" => "766152fc8f1bcbb41b9c0b7287caf911"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/cells/decidim/meetings/join_meeting_button/show.erb" => "aedb2460af3d4a7de566ddf27b60109e"
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
