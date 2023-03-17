require 'uri'
require 'optparse'
require 'fetch/fetcher'
require 'fetch/error'

module Fetch
  class CLI
    def self.start(args)
      new.start(args)
    rescue Fetch::Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    def initialize(download_dir: Dir.pwd)
      @options = {}
      @download_dir = download_dir
    end

    def start(args)
      OptionParser.new do |opt|
        opt.banner = 'Usage: fetch [options] <url> <url> <url> ...'
        opt.on('--metadata', 'Fetch metadata only') do |m|
          @options[:metadata] = m
        end
      end.parse!(args)

      if @options[:metadata]
        show_metadata(args.first)
      else
        fetch(args)
      end
    end

    private

    def fetch(urls)
      urls.each do |url|
        body, metadata = Fetch::Fetcher.fetch(url)
        filename = "#{url_to_filename_prefix(url)}.html"
        File.write(File.join(@download_dir, filename), body)

        metadata_filename = "#{url_to_filename_prefix(url)}.metadata.json"
        File.write(File.join(@download_dir, metadata_filename), metadata.to_json)
      end
    end

    def show_metadata(url)
      p "Showing metadata for #{url}"
    end

    def url_to_filename_prefix(url)
      uri = URI.parse(url)
      host = uri.host

      path = (uri.path.gsub('/', '_') if uri.path != '/')

      "#{host}#{path}"
    end
  end
end
