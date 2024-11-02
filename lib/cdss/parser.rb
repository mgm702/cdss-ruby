module Cdss
  class Parser
    class << self
      def parse_station(response)
        return nil unless response['ResultList']&.first

        data = response['ResultList'].first
        build_station(data)
      end

      def parse_stations(response)
        return [] unless response['ResultList']

        response['ResultList'].map { |data| build_station(data) }
      end

      def parse_readings(response, timescale:)
        return [] unless response['ResultList']

        response['ResultList'].map do |reading|
          build_reading(reading, timescale)
        end
      end

      private

      def build_station(data)
        Cdss::Models::Station.new(
          station_num: data['stationNum'],
          abbrev: data['abbrev'],
          usgs_site_id: data['usgsSiteId'],
          name: data['stationName'],
          agency: data['dataSource'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          division: data['division'],
          water_district: data['waterDistrict'],
          county: data['county'],
          state: data['state'],
          utm_x: data['utmX'],
          utm_y: data['utmY'],
          location_accuracy: data['locationAccuracy'],
          start_date: parse_timestamp(data['startDate']),
          end_date: parse_timestamp(data['endDate']),
          modified: parse_timestamp(data['modified']),
          more_information: data['moreInformation'],
          meas_unit: data['measUnit'],
          metadata: {}
        )
      end

      def build_reading(data, timescale)
        base_params = {
          station_num: data['stationNum'],
          abbrev: data['abbrev'],
          parameter: data['parameter'],
          usgs_site_id: data['usgsSiteId'],
          meas_type: data['measType'],
          meas_unit: data['measUnit'],
          meas_count: data['measCount']&.to_i,
          meas_value: data['measValue']&.to_f,
          meas_date: parse_timestamp(data['measDate']),
          meas_date_time: parse_timestamp(data['measDateTime']),
          data_source: data['dataSource'],
          modified: parse_timestamp(data['modified']),
          metadata: {}
        }

        case timescale
        when :day
          Cdss::Models::Reading.new(
            **base_params,
            value: data['value'].to_f,
            flags: {
              flagA: data['flagA'],
              flagB: data['flagB'],
              flagC: data['flagC'],
              flagD: data['flagD']
            },
          )
        when :month
          Cdss::Models::Reading.new(
            **base_params,
            cal_year: data['calYear'].to_i,
            cal_month_num: data['calMonNum'].to_i,
            min_q_cfs: data['minQCfs'].to_f,
            max_q_cfs: data['maxQCfs'].to_f,
            avg_q_cfs: data['avgQCfs'].to_f,
            total_q_af: data['totalQAf'].to_f,
          )
        when :year
          Cdss::Models::Reading.new(
            **base_params,
            water_year: data['waterYear'].to_i,
            min_q_cfs: data['minQCfs'].to_f,
            max_q_cfs: data['maxQCfs'].to_f,
            avg_q_cfs: data['avgQCfs'].to_f,
            total_q_af: data['totalQAf'].to_f,
          )
        when :raw
          Cdss::Models::Reading.new(
            **base_params,
            flags: {
              flagA: data['flagA'],
              flagB: data['flagB'],
            },
          )
        when :hour
          Cdss::Models::Reading.new(
            **base_params,
            flags: {
              flagA: data['flagA'],
              flagB: data['flagB'],
            },
          )
        else
          raise ArgumentError, "Invalid timescale: #{timescale}"
        end
      end

      def parse_timestamp(datetime_str)
        Time.parse(datetime_str) if datetime_str
      rescue ArgumentError
        nil
      end
    end
  end
end
