# frozen_string_literal: true

module Cdss
  # The Parser class handles parsing of response data from the CDSS API into domain objects.
  # It delegates the actual parsing work to specialized parser modules for each data type.
  class Parser
    class << self
      # Parses station data from the API response.
      #
      # @param response [Hash] The API response containing station data.
      # @return [Array<Station>] Array of Station objects representing telemetry or surface water stations.
      # @example Parse stations from API response
      #   stations = Parser.parse_stations(response_data)
      def parse_stations(response)
        Parsers::StationParser.parse_stations(response)
      end

      # Parses time series readings from the API response.
      #
      # @param response [Hash] The API response containing reading data.
      # @param timescale [Symbol] The timescale of the readings (:day, :month, :year, :raw, :hour).
      # @return [Array<Reading>] Array of Reading objects with time series data.
      # @raise [ArgumentError] If an invalid timescale is provided.
      # @example Parse daily readings
      #   readings = Parser.parse_readings(response_data, timescale: :day)
      def parse_readings(response, timescale:)
        Parsers::ReadingParser.parse_readings(response, timescale: timescale)
      end

      # Parses well data from the API response.
      #
      # @param response [Hash] The API response containing well data.
      # @return [Array<Well>] Array of Well objects with basic well information.
      # @example Parse wells from response
      #   wells = Parser.parse_wells(response_data)
      def parse_wells(response)
        Parsers::WellParser.parse_wells(response)
      end

      # Parses well measurement data from the API response.
      #
      # @param response [Hash] The API response containing well measurement data.
      # @return [Array<Reading>] Array of Reading objects containing well measurements.
      # @example Parse well measurements
      #   measurements = Parser.parse_well_measurements(response_data)
      def parse_well_measurements(response)
        Parsers::WellParser.parse_well_measurements(response)
      end

      # Parses geophysical well data from the API response.
      #
      # @param response [Hash] The API response containing geophysical well data.
      # @return [Array<Well>] Array of Well objects with geophysical well information.
      # @example Parse geophysical wells
      #   geo_wells = Parser.parse_geophysical_wells(response_data)
      def parse_geophysical_wells(response)
        Parsers::WellParser.parse_geophysical_wells(response)
      end

      # Parses geophysical log pick data from the API response.
      #
      # @param response [Hash] The API response containing log pick data.
      # @return [Array<Reading>] Array of Reading objects containing log pick information.
      # @example Parse log picks for a well
      #   picks = Parser.parse_log_picks(response_data)
      def parse_log_picks(response)
        Parsers::WellParser.parse_log_picks(response)
      end

      # Parses water rights data from the API response.
      #
      # @param response [Hash] The API response containing water rights data.
      # @param type [Symbol] The type of water rights data to parse (:net_amount or :transaction).
      # @return [Array<WaterRight>] Array of WaterRight objects.
      # @raise [ArgumentError] If an invalid water rights type is provided.
      # @example Parse net amounts
      #   rights = Parser.parse_water_rights(response_data, type: :net_amount)
      # @example Parse transactions
      #   transactions = Parser.parse_water_rights(response_data, type: :transaction)
      def parse_water_rights(response, type:)
        Parsers::WaterRightsParser.parse_water_rights(response, type: type)
      end

      # Parses climate station data from the API response.
      #
      # @param response [Hash] The API response containing climate station data.
      # @return [Array<ClimateStation>] Array of climate station objects.
      def parse_climate_stations(response)
        Parsers::ClimateParser.parse_climate_stations(response)
      end

      # Parses climate reading data from the API response.
      #
      # @param response [Hash] The API response containing climate readings.
      # @param type [Symbol] The type of climate reading (:frost_dates, :daily, or :monthly).
      # @return [Array<Reading>] Array of climate reading objects.
      # @raise [ArgumentError] If an invalid reading type is provided.
      def parse_climate_readings(response, type:)
        Parsers::ClimateParser.parse_climate_readings(response, type: type)
      end

      # Parses administrative calls data from the API response.
      #
      # @param response [Hash] The API response containing administrative calls data.
      # @return [Array<AdminCall>] Array of administrative call objects.
      # @example Parse admin calls from response
      #   calls = Parser.parse_admin_calls(response_data)
      def parse_admin_calls(response)
        Parsers::AdminCallsParser.parse_admin_calls(response)
      end

      # Parses call analysis data from the API response.
      #
      # @param response [Hash] The API response containing call analysis data.
      # @param type [Symbol] The type of analysis (:wdid or :gnis).
      # @return [Array<CallAnalysis>] Array of call analysis objects.
      # @raise [ArgumentError] If an invalid analysis type is provided.
      def parse_call_analyses(response, type:)
        Parsers::AnalysisParser.parse_call_analyses(response, type: type)
      end

      # Parses source route framework data from the API response.
      #
      # @param response [Hash] The API response containing source route data.
      # @return [Array<SourceRoute>] Array of source route objects.
      def parse_source_routes(response)
        Parsers::AnalysisParser.parse_source_routes(response)
      end

      # Parses route analysis data from the API response.
      #
      # @param response [Hash] The API response containing route analysis data.
      # @return [Array<RouteAnalysis>] Array of route analysis objects.
      def parse_route_analyses(response)
        Parsers::AnalysisParser.parse_route_analyses(response)
      end

      # Parses structure data from the API response.
      #
      # @param response [Hash] The API response containing structure data.
      # @return [Array<Cdss::Models::Structure>] Array of structure objects.
      def parse_structures(response)
        Parsers::StructuresParser.parse_structures(response)
      end

      # Parses diversion record data from the API response.
      #
      # @param response [Hash] The API response containing diversion record data.
      # @param type [Symbol] The type of record (:day, :month, :year, or :stage_volume).
      # @return [Array<Cdss::Models::DiversionRecord>] Array of diversion record objects.
      def parse_diversion_records(response, type:)
        Parsers::StructuresParser.parse_diversion_records(response, type: type)
      end

      # Parses water class data from the API response.
      #
      # @param response [Hash] The API response containing water class data.
      # @return [Array<Cdss::Models::WaterClass>] Array of water class objects.
      def parse_water_classes(response)
        Parsers::StructuresParser.parse_water_classes(response)
      end

      # Parses reference table data from the API response.
      #
      # @param response [Hash] The API response containing reference table data.
      # @return [Array<Cdss::Models::ReferenceTable>] Array of reference table objects.
      def parse_reference_table(response)
        Parsers::ReferenceTablesParser.parse_reference_table(response)
      end
    end
  end
end
