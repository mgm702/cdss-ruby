# frozen_string_literal: true

module Cdss
  module Parsers
    module ReadingParser
      extend BaseParser

      class << self
        def parse_readings(response, timescale:)
          parse_collection(response) { |data| build_reading(data, timescale) }
        end

        private

        def build_reading(data, timescale)
          params = build_base_params(data)
          add_timescale_params(params, data, timescale)
          Cdss::Models::Reading.new(**params)
        end

        def build_base_params(data)
          {
            station_num: data["stationNum"],
            abbrev: data["abbrev"],
            parameter: data["parameter"],
            usgs_site_id: data["usgsSiteId"],
            meas_type: data["measType"],
            meas_unit: data["measUnit"],
            meas_count: safe_integer(data["measCount"]),
            meas_value: safe_float(data["measValue"]),
            meas_date: parse_timestamp(data["measDate"]),
            meas_date_time: parse_timestamp(data["measDateTime"]),
            data_source: data["dataSource"],
            modified: parse_timestamp(data["modified"]),
            metadata: {}
          }
        end

        def add_timescale_params(params, data, timescale)
          case timescale
          when :day then add_day_params(params, data)
          when :month then add_month_params(params, data)
          when :year, :water_year then add_year_params(params, data)
          when :raw, :hour then add_raw_params(params, data)
          else
            raise ArgumentError, "Invalid timescale: #{timescale}"
          end
        end

        def add_day_params(params, data)
          params[:value] = safe_float(data["value"])
          params[:flags] = {
            flagA: data["flagA"],
            flagB: data["flagB"],
            flagC: data["flagC"],
            flagD: data["flagD"]
          }
        end

        def add_month_params(params, data)
          params.merge!(
            cal_year: safe_integer(data["calYear"]),
            cal_month_num: safe_integer(data["calMonNum"]),
            min_q_cfs: safe_float(data["minQCfs"]),
            max_q_cfs: safe_float(data["maxQCfs"]),
            avg_q_cfs: safe_float(data["avgQCfs"]),
            total_q_af: safe_float(data["totalQAf"])
          )
        end

        def add_year_params(params, data)
          params.merge!(
            water_year: safe_integer(data["waterYear"]),
            min_q_cfs: safe_float(data["minQCfs"]),
            max_q_cfs: safe_float(data["maxQCfs"]),
            avg_q_cfs: safe_float(data["avgQCfs"]),
            total_q_af: safe_float(data["totalQAf"])
          )
        end

        def add_raw_params(params, data)
          params[:flags] = {
            flagA: data["flagA"],
            flagB: data["flagB"]
          }
        end
      end
    end
  end
end
