# frozen_string_literal: true

Rails.application.config.to_prepare do
  Aws::S3::Object.class_eval do
    def public_url(options = {})
      bucket_url = if ENV["AWS_CDN_HOST"].present? && ENV["AWS_CDN_HOST"].starts_with?("https://")
                     ENV.fetch("AWS_CDN_HOST", nil)
                   else
                     bucket.url(options)
                   end
      url = URI.parse(bucket_url)
      url.path += "/" unless url.path[-1] == "/"
      url.path += key.gsub(%r{[^/]+}) { |s| Seahorse::Util.uri_escape(s) }
      url.to_s
    end
  end

  # This is a hack to temporarily fix https://github.com/decidim/decidim/issues/14668
  Aws::S3::Presigner.class_eval do
    def presigned_url(method, params = {})
      params.delete(:host) if params.has_key?(:host)
      url, _headers = _presigned_request(method, params)
      url
    end
  end
end
