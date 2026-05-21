# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/decidim/account/show.html.erb" => "1c230c5c6bc02e0bb22e1ea92b0da96c", # blocks email editing
      "/app/views/decidim/devise/sessions/new.html.erb" => "da0d18178c8dcead2774956e989527c5", # adds link to civicrm signup
      # concerns
      "/app/controllers/concerns/decidim/force_authentication.rb" => "fb182e6efdbc34a9d2b75aa4df06faa1",
      "/app/views/layouts/decidim/header/_main.html.erb" => "a090eeca739613446d2eab8f4de513b1", # add language chooser to header
      "/app/presenters/decidim/official_author_presenter.rb" => "dbfb2fefa1c75d703e65443cd68014c2"
    }
  },
  {
    package: "decidim-participatory_processes",
    files: {
      # views
      "/app/views/decidim/participatory_processes/participatory_processes/index.html.erb" => "8ef7c51e040a5848519d64eba67146c7" # processes index page
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/controllers/decidim/meetings/directory/meetings_controller.rb" => "cae2c841a3b115a4a8a13a07254bbe0a"
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
