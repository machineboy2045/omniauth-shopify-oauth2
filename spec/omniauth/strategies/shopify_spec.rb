require 'spec_helper'

describe OmniAuth::Strategies::Shopify do
  before :each do
    @request = double('Request',
                      :env => { })
    @request.stub(:params) do
      {shop: 'https://example.myshopify.com'}
    end
    @request.stub(:cookies) { {} }

    @client_id = '123'
    @client_secret = '53cr3tz'

    @options = {}
  end

  subject do
    args = [@client_id, @client_secret, @options].compact
    OmniAuth::Strategies::Shopify.new(nil, *args).tap do |strategy|
      strategy.stub(:request) { @request }
      strategy.stub(:session) { {} }
    end
  end

  describe '#client' do
    it 'has correct authorize url' do
      expect(subject.client.options[:authorize_url]).to eq('/admin/oauth/authorize')
    end

    it 'has correct token url' do
      expect(subject.client.options[:token_url]).to eq('/admin/oauth/access_token')
    end
  end

  describe '#callback_url' do
    it "defaults to callback" do
      url_base = 'https://auth.request.com'
      @request.stub(:url) { "#{url_base}/page/path" }
      @request.stub(:scheme) { 'http' }
      subject.stub(:script_name) { "" } # to not depend from Rack env
      expect(subject.callback_url).to eq("#{url_base}/auth/shopify/callback")
    end
  end

  describe '#authorize_params' do
    it 'includes default scope for read_products' do
      expect(subject.authorize_params).to be_a(Hash)
      expect(subject.authorize_params[:scope]).to eq('write_products,write_orders')
    end
  end

  describe '#shop' do
    it 'returns the shop' do
      expect(subject.shop).to eq('https://example.myshopify.com')
    end
  end

  describe '#uid' do
    it 'returns the shop' do
      expect(subject.uid).to eq('example')
    end
  end

  describe '#credentials' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      @access_token.stub(:token)
      @access_token.stub(:expires?)
      @access_token.stub(:expires_at)
      @access_token.stub(:refresh_token)
      subject.stub(:access_token) { @access_token }
    end

    it 'returns a Hash' do
      expect(subject.credentials).to be_a(Hash)
    end

    it 'returns the token' do
      @access_token.stub(:token) { '123' }
      expect(subject.credentials['token']).to eq('123')
    end

    it 'returns the expiry status' do
      @access_token.stub(:expires?) { true }
      expect(subject.credentials['expires']).to eq(true)

      @access_token.stub(:expires?) { false }
      expect(subject.credentials['expires']).to eq(false)
    end

  end


end
