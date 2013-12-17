require 'aker'

module Aker::Cas::Middleware
  class LogoutResponder
    include Aker::Rack::ConfigurationHelper
    include ::Rack::Utils

    ##
    # @param app a Rack app
    # @param [String] cas_logout_url the CAS logout URL
    def initialize(app)
      @app = app
    end

    ##
    # Rack entry point.
    #
    # Given a `GET` to the configured logout path, redirects to
    # {#cas_logout_url}.  All other requests are passed through.
    #
    # @see http://www.jasig.org/cas/protocol
    #      Section 2.3 of the CAS 2 protocol
    def call(env)
      if env['REQUEST_METHOD'] == 'GET' && env['PATH_INFO'] == logout_path(env)
        ::Rack::Response.new { |r| r.redirect(cas_logout_url(env)) }.finish
      else
        @app.call(env)
      end
    end

    private

    def cas_logout_url(env)
      logout_uri = configuration(env).parameters_for(:cas)[:logout_url] || URI.join(cas_url(env), 'logout')
      request =::Rack::Request.new(env)
      # url = "#{request.scheme}://#{request.host}"
      url = AudiologyRegistry::Application.config.crr_website_url
      unless [ ["https", 443], ["http", 80] ].include?([request.scheme, request.port])
                  url << ":#{request.port}"
      end
      logout_uri.query  = "service=#{escape(url)}"
      logout_uri.to_s
    end

    def cas_url(env)
      appending_forward_slash do
        configuration(env).parameters_for(:cas)[:base_url] ||
          configuration(env).parameters_for(:cas)[:cas_base_url]
      end
    end

    def appending_forward_slash
      url = yield

      (url && url[-1].chr != '/') ? url + '/' : url
    end
  end
end
