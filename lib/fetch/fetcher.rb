require 'httparty'

module Fetch
  module Fetcher
    extend self

    def fetch(url)
      raise Fetch::Error, "Invalid URL: #{url}" unless valid_url?(url)

      response = HTTParty.get(url, follow_redirects: true)

      raise Fetch::Error, "Fetching #{url} failed: #{response.code}" unless response.success?

      content_type = response.headers['content-type']
      raise Fetch::Error, "#{url} is not an HTML document" unless content_type&.include?('text/html')

      response.body
    end

    private

    def valid_url?(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end
  end
end
