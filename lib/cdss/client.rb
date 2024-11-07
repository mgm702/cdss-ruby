require_relative 'telemetry'
require_relative 'surface_water'
require_relative 'ground_water'
require_relative 'water_rights'
require_relative 'climate'
require_relative 'admin_calls'
require_relative 'analysis'
require_relative 'structures'
require_relative 'reference_tables'

module Cdss
  class Client
    include HTTParty

    base_uri Cdss.config.base_url

    include AdminCalls
    include Climate
    include GroundWater
    include Structures
    include SurfaceWater
    include Telemetry
    include WaterRights
    include ReferenceTables

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
