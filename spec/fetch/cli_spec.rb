require 'fetch/cli'
require 'tmpdir'

RSpec.describe Fetch::CLI do
  describe '#start' do
    let(:download_dir) { Dir.mktmpdir }

    around do |example|
      example.run
    ensure
      FileUtils.remove_entry(download_dir)
    end

    context 'when ./fetch [url] [url] ...' do
      let(:cli) { described_class.new(download_dir: download_dir) }
      let(:urls) { ['http://example.com/', 'https://www.google.com'] }

      it 'writes fetched contents to files' do
        allow(Fetch::Fetcher).to receive(:fetch).with('http://example.com/').and_return('<html>example.com</html>')
        allow(Fetch::Fetcher).to receive(:fetch).with('https://www.google.com').and_return('<html>google.com</html>')

        cli.start(urls)

        expect(File.read(File.join(download_dir, 'example.com.html'))).to eq '<html>example.com</html>'
        expect(File.read(File.join(download_dir, 'www.google.com.html'))).to eq '<html>google.com</html>'
      end
    end
  end
end
