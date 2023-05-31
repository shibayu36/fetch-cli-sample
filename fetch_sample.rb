require 'httparty'
require 'nokogiri'

def valid_url?(url)
  uri = URI.parse(url)
  uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
rescue URI::InvalidURIError
  false
end

def fetch_html(url)
  raise "Invalid URL '#{url}'" unless valid_url?(url)

  response = HTTParty.get(url, follow_redirects: true)

  raise "Fetching #{url} failed: #{response.code}" unless response.success?

  content_type = response.headers['content-type']
  raise "#{url} is not an HTML document" unless content_type&.include?('text/html')

  response.body
end

begin
  url = ARGV[0]
  html = fetch_html(url)
  puts "Fetched HTML content for: #{url}"
  puts html

  puts '======= metadata ======='
  parser = Nokogiri::HTML(html)
  num_links = parser.css('a').count
  num_imgs = parser.css('img').count
  puts "num_links: #{num_links}"
  puts "num_imgs: #{num_imgs}"
rescue RuntimeError => e
  puts "Error: #{e.message}"
end
