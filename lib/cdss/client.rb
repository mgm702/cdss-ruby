require_relative 'telemetry'
require_relative 'surface_water'
require_relative 'ground_water'
require_relative 'water_rights'
require_relative 'climate'

module Cdss
  class Client
    include HTTParty

    base_uri Cdss.config.base_url

    include Telemetry
    include SurfaceWater
    include GroundWater
    include WaterRights
    include Climate

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
