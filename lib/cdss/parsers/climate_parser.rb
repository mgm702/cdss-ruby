module Cdss
  module Parsers
    module ClimateParser
      extend BaseParser

      class << self
        def parse_climate_stations(response)
          parse_collection(response) { |data| build_station(data) }
        end

        def parse_climate_readings(response, type:)
          parse_collection(response) { |data| build_reading(data, type) }
        end

        private

        def build_station(data)
          Cdss::Models::ClimateStation.new(
            station_number: data['stationNum'],
            station_name: data['stationName'],
            site_id: data['siteId'],
            division: data['division']&.to_i,
            water_district: data['waterDistrict']&.to_i,
            county: data['county'],
            state: data['state'],
            latitude: data['latitude']&.to_f,
            longitude: data['longitude']&.to_f,
            utm_x: data['utmX']&.to_f,
            utm_y: data['utmY']&.to_f,
            elevation: data['elevation']&.to_f,
            data_source: data['dataSource'],
            start_date: parse_timestamp(data['startDate']),
            end_date: parse_timestamp(data['endDate']),
            modified: parse_timestamp(data['modified']),
            more_information: data['moreInformation'],
            parameter_types: data['parameterTypes'],
            metadata: {}
          )
        end

        def build_reading(data, type)
          base_params = {
            station_number: data['stationNum'],
            site_id: data['siteId'],
            parameter: data['measType'],
            data_source: data['dataSource'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          }

          case type
          when :frost_dates
            base_params.merge!(
              cal_year: data['calYear']&.to_i,
              spring_frost_date: parse_timestamp(data['springFrostDate']),
              fall_frost_date: parse_timestamp(data['fallFrostDate']),
              frost_date_28f_spring: parse_timestamp(data["l28s"]),
              frost_date_28f_fall: parse_timestamp(data["f28s"]),
              frost_date_32f_spring: parse_timestamp(data["l32s"]),
              frost_date_32f_fall: parse_timestamp(data["f32f"]),
            )
          when :daily
            base_params.merge!(
              meas_date: parse_timestamp(data['measDate']),
              value: data['value']&.to_f,
              flag: data['flag'],
              units: data['units']
            )
          when :monthly
            base_params.merge!(
              cal_year: data['calYear']&.to_i,
              cal_month: data['calMonth']&.to_i,
              value: data['value']&.to_f,
              flag: data['flag'],
              units: data['units']
            )
          end

          Cdss::Models::Reading.new(**base_params)
        end
      end
    end
  end
end
