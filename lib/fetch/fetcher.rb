require 'httparty'
require 'nokogiri'
require 'fetch/error'

module Fetch
  module Fetcher
    extend self

    def fetch(url)
      raise Fetch::Error, "Invalid URL: #{url}" unless valid_url?(url)

      response = HTTParty.get(url, follow_redirects: true)

      raise Fetch::Error, "Fetching #{url} failed: #{response.code}" unless response.success?

      content_type = response.headers['content-type']
      raise Fetch::Error, "#{url} is not an HTML document" unless content_type&.include?('text/html')

      [response.body, create_metadata(response.body)]
    end

    private

    def valid_url?(url)
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end

    def create_metadata(body)
      parser = Nokogiri::HTML(body)
      num_links = parser.css('a').count
      num_imgs = parser.css('img').count
      last_fetched = Time.now.utc.strftime('%a %b %d %Y %H:%M %Z')

      {
        num_links: num_links,
        num_imgs: num_imgs,
        last_fetched: last_fetched
      }
    end
  end
end
