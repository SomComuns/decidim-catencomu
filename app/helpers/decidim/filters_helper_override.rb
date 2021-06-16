# frozen_string_literal: true

module Decidim
  module FiltersHelperOverride
    extend ActiveSupport::Concern

    included do
      # url_for does not detect the current path
      def filter_form_for(filter, url = detect_url, html_options = {})
        content_tag :div, class: "filters" do
          form_for(
            filter,
            namespace: filter_form_namespace,
            builder: FilterFormBuilder,
            url: url,
            as: :filter,
            method: :get,
            remote: true,
            html: { id: nil }.merge(html_options)
          ) do |form|
            yield form
          end
        end
      end

      private

      def detect_url
        return request.path if request.present?

        url_for
      end
    end
  end
end
