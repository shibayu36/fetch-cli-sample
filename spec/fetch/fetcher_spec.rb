require 'fetch/fetcher'
require 'fetch/error'

RSpec.describe Fetch::Fetcher do
  describe '.fetch' do
    let(:url) { 'http://example.com' }
    let(:html) { '<html><body><h1>Hello, World!</h1></body></html>' }

    context 'when url is valid, and HTML is fetched' do
      before do
        stub_request(:get, url)
          .to_return(status: 200, body: html, headers: { 'Content-Type': 'text/html' })
      end

      it 'fetches HTML content from a given URL' do
        expect(described_class.fetch(url)).to eq(html)
      end
    end

    context 'when URL is invalid' do
      let(:invalid_url) { 'invalid_url' }

      it 'raises an error' do
        expect { described_class.fetch(invalid_url) }.to raise_error(Fetch::Error, "Invalid URL: #{invalid_url}")
      end
    end

    context 'when response is not an HTML document' do
      let(:non_html_content) { '{"message": "Hello, World!"}' }

      before do
        stub_request(:get, url)
          .to_return(status: 200, body: non_html_content, headers: { 'Content-Type': 'application/json' })
      end

      it 'raises an error' do
        expect { described_class.fetch(url) }.to raise_error(Fetch::Error, "#{url} is not an HTML document")
      end
    end

    context 'when request fails' do
      before do
        stub_request(:get, url).to_return(status: 404)
      end

      it 'raises an error' do
        expect { described_class.fetch(url) }.to raise_error(Fetch::Error, "Fetching #{url} failed: 404")
      end
    end
  end
end
