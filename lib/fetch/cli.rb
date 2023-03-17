require 'uri'
require 'optparse'
require 'fetch/fetcher'

module Fetch
  class CLI
    def self.start(args)
      exit_code = new.start(args)
      exit exit_code
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

      0
    end

    private

    def fetch(urls)
      urls.each do |url|
        body = Fetch::Fetcher.fetch(url)
        filename = "#{url_to_filename_prefix(url)}.html"
        File.write(File.join(@download_dir, filename), body)
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
