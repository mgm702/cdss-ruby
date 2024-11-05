module Cdss
  class Parser
    class << self
      def parse_stations(response)
        Parsers::StationParser.parse_stations(response)
      end

      def parse_readings(response, timescale:)
        Parsers::ReadingParser.parse_readings(response, timescale: timescale)
      end

      def parse_wells(response)
        Parsers::WellParser.parse_wells(response)
      end

      def parse_well_measurements(response)
        Parsers::WellParser.parse_well_measurements(response)
      end

      def parse_geophysical_wells(response)
        Parsers::WellParser.parse_geophysical_wells(response)
      end

      def parse_log_picks(response)
        Parsers::WellParser.parse_log_picks(response)
      end
    end
  end
end
