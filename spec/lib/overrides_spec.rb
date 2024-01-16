# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/layouts/decidim/_main_footer.html.erb" => "4b19823c90e8473f03b5e9257c506b3e", # centered organization logo
      "/app/views/decidim/account/show.html.erb" => "567f47fd001a0222943579d9ebfe5f3a", # blocks email editing
      "/app/views/decidim/devise/omniauth_registrations/new.html.erb" => "81d19863520eb70fd228deec786e739a", # blocks email editing
      "/app/views/decidim/devise/sessions/new.html.erb" => "9d090fc9e565ded80a9330d4e36e495c", # adds link to civicrm signup
      # concerns
      "/app/controllers/concerns/decidim/force_authentication.rb" => "c1fa7a3c6d014c3d47985536a16ee243",
      # helpers
      "/app/helpers/decidim/filters_helper.rb" => "23b62d7deb2b1fc48b01e33a549c812c"
    }
  },
  {
    package: "decidim-participatory_processes",
    files: {
      # views
      "/app/views/decidim/participatory_processes/participatory_processes/index.html.erb" => "2101e198c970bd632f24e8be725d1b82", # processes index page
      "/app/views/layouts/decidim/_process_navigation.html.erb" => "e4d2322544d80ef4452aa61425034aa3",
      # models
      "/app/models/decidim/participatory_process.rb" => "46c871ef5eb357768c97b3dbc69514a0",
      # cells
      "/app/cells/decidim/participatory_processes/process_filters_cell.rb" => "cd83acfcd8865c5fe1dbcf8deb5bf319",
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
      "/app/cells/decidim/meetings/join_meeting_button/show.erb" => "66ee99695217f75939deed77f6f88159"
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
