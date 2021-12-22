# frozen_string_literal: true

require "rake"

class SyncCivicrmWorker
  include Sidekiq::Worker

  def perform(*_args)
    Decidim::Organization.find_each do |organization|
      Civicrm::SyncAllGroupsJob.perform_now(organization.id)
    end
  end
end
