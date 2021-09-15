# frozen_string_literal: true

module Managers
  module Admin
    class ProcessForm < Decidim::Form
      include Decidim::TranslatableAttributes

      translatable_attribute :title, String
      attribute :group_id, Integer
      attribute :title, String
    end
  end
end
