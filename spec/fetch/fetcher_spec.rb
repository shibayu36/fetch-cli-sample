require 'timecop'
require 'fetch/fetcher'
require 'fetch/error'

RSpec.describe Fetch::Fetcher do
  describe '.fetch' do
    let(:url) { 'http://example.com' }

    context 'when url is valid, and HTML is fetched' do
      let(:html) { '<html><body><h1>Hello, World!</h1></body></html>' }

      before do
        stub_request(:get, url)
          .to_return(status: 200, body: html, headers: { 'Content-Type': 'text/html' })
      end

      it 'fetches HTML content from a given URL' do
        Timecop.freeze(Time.utc(2023, 3, 17, 11, 23)) do
          body, metadata = described_class.fetch(url)
          expect(body).to eq(html)
          expect(metadata).to eq(
            {
              num_links: 0,
              num_imgs: 0,
              last_fetched: 'Fri Mar 17 2023 11:23 UTC'
            }
          )
        end
      end

      context 'when HTML has some imgs and links' do
        let(:html) { '<html><body><a href="/hoge"><img src="/hoge.png" /></a><img src="fuga.jpg" /></body></html>' }

        it 'returns num_links and num_imgs in metadata' do
          _, metadata = described_class.fetch(url)

          expect(metadata).to include(
            num_links: 1,
            num_imgs: 2
          )
        end
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
