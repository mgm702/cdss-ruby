# frozen_string_literal: true

module Cdss
  module Climate
    include Utils

    def get_climate_stations(aoi: nil, radius: nil, county: nil, division: nil, station_name: nil, site_id: nil,
                             water_district: nil)
      query_params = {
        dateFormat: "spaceSepToSeconds",
        units: "miles",
        county: county,
        division: division,
        stationName: station_name,
        siteId: site_id,
        waterDistrict: water_district
      }

      if aoi
        if aoi.is_a?(Hash) && aoi[:latitude] && aoi[:longitude]
          query_params.merge!(longitude: aoi[:longitude], latitude: aoi[:latitude])
        elsif aoi.is_a?(Array) && aoi.count == 2
          query_params.merge!(longitude: aoi[0], latitude: aoi[1])
        else
          raise ArgumentError, "Invalid 'aoi' parameter"
        end
        query_params[:radius] = radius || 20
      end

      fetch_paginated_data(
        endpoint: "/climatedata/climatestations/",
        query: query_params
      ) { |data| Parser.parse_climate_stations(data) }
    end

    def get_climate_frost_dates(station_number:, start_date: nil, end_date: nil)
      query_params = {
        dateFormat: "spaceSepToSeconds",
        stationNum: station_number
      }

      query_params[:"min-calYear"] = start_date.strftime("%Y") if start_date
      query_params[:"max-calYear"] = end_date.strftime("%Y") if end_date

      fetch_paginated_data(
        endpoint: "/climatedata/climatestationfrostdates/",
        query: query_params
      ) { |data| Parser.parse_climate_readings(data, type: :frost_dates) }
    end

    def get_climate_ts_day(param:, station_number: nil, site_id: nil, start_date: nil, end_date: nil)
      query_params = {
        dateFormat: "spaceSepToSeconds",
        measType: param,
        stationNum: station_number,
        siteId: site_id
      }

      query_params[:"min-measDate"] = start_date.strftime("%m-%d-%Y") if start_date
      query_params[:"max-measDate"] = end_date.strftime("%m-%d-%Y") if end_date

      fetch_paginated_data(
        endpoint: "/climatedata/climatestationtsday/",
        query: query_params
      ) { |data| Parser.parse_climate_readings(data, type: :daily) }
    end

    def get_climate_ts_month(param:, station_number: nil, site_id: nil, start_date: nil, end_date: nil)
      query_params = {
        dateFormat: "spaceSepToSeconds",
        measType: param,
        stationNum: station_number,
        siteId: site_id
      }

      query_params[:"min-calYear"] = start_date.strftime("%Y") if start_date
      query_params[:"max-calYear"] = end_date.strftime("%Y") if end_date

      fetch_paginated_data(
        endpoint: "/climatedata/climatestationtsmonth/",
        query: query_params
      ) { |data| Parser.parse_climate_readings(data, type: :monthly) }
    end

    def get_climate_ts(station_number: nil, site_id: nil, param: nil, start_date: nil, end_date: nil, timescale: "day")
      valid_params = %w[Evap FrostDate MaxTemp MeanTemp MinTemp Precip Snow SnowDepth SnowSWE Solar VP Wind]
      raise ArgumentError, "Invalid parameter: '#{param}'. Valid values are: #{valid_params.join(', ')}" unless valid_params.include?(param)

      day_formats = %w[day days daily d]
      month_formats = %w[month months monthly mon m]
      timescale = timescale.to_s.downcase

      case timescale
      when *day_formats
        get_climate_ts_day(station_number: station_number, site_id: site_id, param: param,
                           start_date: start_date, end_date: end_date)
      when *month_formats
        get_climate_ts_month(station_number: station_number, site_id: site_id, param: param,
                             start_date: start_date, end_date: end_date)
      else
        raise ArgumentError, "Invalid timescale: '#{timescale}'. Use 'day' or 'month'."
      end
    end
  end
end
