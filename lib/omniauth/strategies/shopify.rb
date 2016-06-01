require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Shopify < OmniAuth::Strategies::OAuth2
      MINUTE = 60
      CODE_EXPIRES_AFTER = 10 * MINUTE

      option :client_options, {
        :authorize_url => '/admin/oauth/authorize',
        :token_url => '/admin/oauth/access_token'
      }

      option :callback_url
      option :myshopify_domain, 'myshopify.com'

      def shop
        request.params['shop'] || request.params[:shop]
      end

      uid do
        shop
          .gsub(/https?:\/\//, '') # remove http:// or https://
          .gsub(/\..*/, '') # remove .myshopify.com
      end

      def self.encoded_params_for_signature(params)
        params = params.dup
        params.delete('hmac')
        params.delete('signature') # deprecated signature
        params.map{|k,v| "#{URI.escape(k.to_s, '&=%')}=#{URI.escape(v.to_s, '&%')}"}.sort.join('&')
      end

      def self.hmac_sign(encoded_params, secret)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, secret, encoded_params)
      end

      def setup_phase
        env['omniauth.strategy'].options[:client_options][:site] = "https://#{uid}.myshopify.com"
        super
      end

      def callback_url
        (options[:callback_url] || full_host + script_name + callback_path)
          .gsub('http://', 'https://') # force https
      end
    end
  end
end
