# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/layouts/decidim/_main_footer.html.erb" => "a26a5a568485d84056f604ef013585a1", # centered organization logo
      "/app/views/decidim/account/show.html.erb" => "2e3c895104e03d7d092467a96f64703d", # blocks email editing
      "/app/views/decidim/devise/omniauth_registrations/new.html.erb" => "d32cbe7f5a60e2892fe3c8cb33b16cda", # blocks email editing
      "/app/views/decidim/devise/sessions/new.html.erb" => "1da8569a34bcd014ffb5323c96391837", # adds link to civicrm signup
      # concerns
      "/app/controllers/concerns/decidim/force_authentication.rb" => "01567b679c74bd9999d4d1cd5647ef73",
      # helpers
      "/app/helpers/decidim/filters_helper.rb" => "566d9e672c96d52415d8ef044bf86cc1"
    }
  },
  {
    package: "decidim-participatory_processes",
    files: {
      # views
      "/app/views/decidim/participatory_processes/participatory_processes/index.html.erb" => "db2daca02aa91c31bbccc365d6cc05ee", # processes index page
      "/app/views/layouts/decidim/_process_navigation.html.erb" => "e4d2322544d80ef4452aa61425034aa3", # max items 7
      # models
      "/app/models/decidim/participatory_process.rb" => "fa9173ec063bdf1e24740873d71ee903",
      # cells
      "/app/cells/decidim/participatory_processes/process_filters_cell.rb" => "97e7a9256b2e7cd3f1eadfd79dfa770a",
      # routes definition
      "/lib/decidim/participatory_processes/engine.rb" => "67194daf21bb580fe083754b0e9da638"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      "/app/views/layouts/decidim/_assembly_navigation.html.erb" => "159f168bf1634937183cf5ca56b03a9d" # max items 7
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
