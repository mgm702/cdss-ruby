require_relative 'telemetry'
require_relative 'surface_water'

module Cdss
  class Client
    include HTTParty
    base_uri Cdss.config.base_url

    include Telemetry
    include SurfaceWater

    private

    def handle_response(response)
      if response.success?
        JSON.parse(response.body)
      else
        raise "API request failed with status #{response.code}: #{response.message}"
      end
    end
  end
end
