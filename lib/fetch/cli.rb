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

      0
    end
  end
end
