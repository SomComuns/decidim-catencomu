# frozen_string_literal: true

require "decidim/civicrm/api"

class AssertionError < RuntimeError
end

def assert(resource = "")
  return puts "OK #{resource}" if yield

  raise AssertionError, "KO #{resource}"
end

def request
  Decidim::Civicrm::Api::Request.new(
    url: ENV.fetch("CIVICRM_VERIFICATION_URL", nil),
    api_key: ENV.fetch("CIVICRM_VERIFICATION_API_KEY", nil),
    key: ENV.fetch("CIVICRM_VERIFICATION_SECRET", nil),
    verify_ssl: false
  )
end

namespace :civicrm do
  namespace :test do
    desc "Test API > All"
    task all: :environment do
      Rake::Task["civicrm:test:get_user"].invoke
      Rake::Task["civicrm:test:fetch_groups"].invoke
      Rake::Task["civicrm:test:users_in_group"].invoke
    end

    desc "Test API > Get user"
    task get_user: :environment do
      user_id = ENV.fetch("CIVICRM_TEST_USER_ID", nil)

      assert("User ID") { user_id.present? }

      user = request.get_user(user_id, with_contact: true)

      assert("#get_user > User") { user.present? }

      %w(id name email contact_id display_name api.Address.get roles).each do |key|
        assert("#get_user > User key '#{key}'") { user.has_key? key }
      end
    end

    desc "Test API > Fetch groups"
    task fetch_groups: :environment do
      groups = request.fetch_groups

      assert("#fetch_groups > Groups") { groups.present? }

      random_group = groups.sample

      [:id, :name, :title, :description, :visibility, :group_type, :is_active, :is_hidden, :is_reserved].each do |key|
        assert("#fetch_groups > Group key '#{key}'") { random_group.has_key? key }
      end
    end

    desc "Test API > Users in group"
    task users_in_group: :environment do
      group_name = ENV.fetch("CIVICRM_TEST_GROUP_NAME", nil)

      assert("Group name") { group_name.present? }

      # Test users in group
      users = request.users_in_group(group_name)

      assert("#users_in_group > Users") { users.present? }

      # keys in user response
      random_user = users.sample
      %w(contact_id display_name groups id api.Usercat.get).each do |key|
        assert("#users_in_group > User key '#{key}'") { random_user.has_key? key }
      end

      # keys in user's nested contact response
      contact = random_user["api.Usercat.get"]["values"][0]
      %w(id name contact_id).each do |key|
        assert("#users_in_group > User > Contact key '#{key}'") { contact.has_key? key }
      end
    end
  end
end
