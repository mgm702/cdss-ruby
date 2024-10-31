module Cdss
  class Parser
    class << self
      def parse_station(response)
        return nil unless response["ResultList"]&.first

        data = response["ResultList"].first
        build_station(data)
      end

      def parse_stations(response)
        return [] unless response["ResultList"]

        response["ResultList"].map { |data| build_station(data) }
      end

      def parse_readings(response)
        return [] unless response["ResultList"]

        response["ResultList"].map do |reading|
          Cdss::Models::Reading.new(
            timestamp: parse_timestamp(reading["measDateTime"] || reading["measDate"]),
            value: reading["measValue"].to_f,
            unit: reading["units"],
            parameter: reading["parameter"],
            quality: reading["flagA"],
            metadata: {
              stage: reading["stage"],
              flag_b: reading["flagB"]
            }
          )
        end
      end

      private

      def build_station(data)
        Cdss::Models::Station.new(
          id: data["abbrev"],
          name: data["stationName"],
          agency: "DWR",
          latitude: data["latitude"],
          longitude: data["longitude"],
          parameters: extract_parameters(data),
          metadata: {
            county: data["county"],
            division: data["division"],
            water_source: data["waterSource"],
            usgs_id: data["usgsStationId"],
            status: data["stationStatus"],
            por_start: data["stationPorStart"],
            por_end: data["stationPorEnd"]
          }
        )
      end

      def parse_timestamp(datetime_str)
        Time.parse(datetime_str)
      rescue
        nil
      end

      def extract_parameters(data)
        ["DISCHRG", "GAGE_HT"].select do |param|
          data[param.downcase]
        end
      end
    end
  end
end
