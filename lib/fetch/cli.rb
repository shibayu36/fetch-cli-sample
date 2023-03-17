require 'optparse'

module Fetch
  class CLI
    def self.start(args)
      exit_code = new.start(args)
      exit exit_code
    end

    def initialize
      @options = {}
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

    def fetch(urls)
      p "Fetching #{urls}"
    end

    def show_metadata(url)
      p "Showing metadata for #{url}"
    end
  end
end
