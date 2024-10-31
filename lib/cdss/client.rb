require_relative 'telemetry'
require_relative 'surface_water'

module Cdss
  class Client
    include HTTParty

    base_uri Cdss.config.base_url

    include Telemetry
    include SurfaceWater

    attr_reader :options

    def initialize(**options)
      @options = options
      setup_client
    end

    private

    def setup_client
      self.class.default_timeout(Cdss.config.timeout)
      self.class.headers({
        'User-Agent' => Cdss.config.user_agent
      })
    end

    def handle_response(response)
      if response.success?
        JSON.parse(response.body)
      else
        raise "API request failed with status #{response.code}: #{response.message}"
      end
    end
  end
end
