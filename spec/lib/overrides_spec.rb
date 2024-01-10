# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/layouts/decidim/_main_footer.html.erb" => "976208c3244dabbfad9c4c24642895fa", # centered organization logo
      "/app/views/decidim/account/show.html.erb" => "db0e241a908e8d72cbd5815a09286e66", # blocks email editing
      "/app/views/decidim/devise/omniauth_registrations/new.html.erb" => "d32cbe7f5a60e2892fe3c8cb33b16cda", # blocks email editing
      "/app/views/decidim/devise/sessions/new.html.erb" => "1da8569a34bcd014ffb5323c96391837", # adds link to civicrm signup
      # concerns
      "/app/controllers/concerns/decidim/force_authentication.rb" => "a74eaaada6356543efc1e4e85619dcab",
      # helpers
      "/app/helpers/decidim/filters_helper.rb" => "23b62d7deb2b1fc48b01e33a549c812c"
    }
  },
  {
    package: "decidim-participatory_processes",
    files: {
      # views
      "/app/views/decidim/participatory_processes/participatory_processes/index.html.erb" => "fc7fec67b9fb9d24b492aad9404c1cc2", # processes index page
      "/app/views/layouts/decidim/_process_navigation.html.erb" => "e4d2322544d80ef4452aa61425034aa3",
      # models
      "/app/models/decidim/participatory_process.rb" => "a20f46b5f0fa44c5f033d5a3152efa92",
      # cells
      "/app/cells/decidim/participatory_processes/process_filters_cell.rb" => "832200340aea29f8ef6bdd578367a8b2",
      # routes definition
      "/lib/decidim/participatory_processes/engine.rb" => "3a1013d23aea78e381c9a6935e68f309"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      "/app/views/layouts/decidim/_assembly_navigation.html.erb" => "159f168bf1634937183cf5ca56b03a9d"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/cells/decidim/meetings/join_meeting_button/show.erb" => "7d85622f4dd6c7a262ab59c53a6aaedf"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    # rubocop:disable Rails/DynamicFindBy
    spec = ::Gem::Specification.find_by_name(item[:package])
    # rubocop:enable Rails/DynamicFindBy
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
