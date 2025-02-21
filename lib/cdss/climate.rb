# frozen_string_literal: true

module Cdss
  # Provides methods for accessing climate data from the CDSS API.
  #
  # This module includes functionality for retrieving climate stations,
  # frost dates, and time series data at various time scales.
  module Climate
    include Utils

    # Fetches climate stations based on various filtering criteria.
    #
    # @param [Hash, Array, nil] aoi Area of interest for spatial searches. If hash, must contain :latitude and :longitude keys.
    #   If array, must contain [longitude, latitude].
    # @param [Integer, nil] radius Radius in miles for spatial search around aoi. Defaults to 20 if aoi is provided.
    # @param [String, nil] county County name to filter stations.
    # @param [Integer, nil] division Water division number to filter stations.
    # @param [String, nil] station_name Name of the station to filter by.
    # @param [String, nil] site_id Station site ID to filter by.
    # @param [Integer, nil] water_district Water district number to filter stations.
    # @return [Array<Station>] Array of matching climate station objects.
    # @raise [ArgumentError] If aoi parameter is provided but invalid.
    # @example Fetch stations in Denver county
    #   get_climate_stations(county: 'Denver')
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

    # Fetches frost dates for a specific climate station.
    #
    # @param [String] station_number Station number to fetch frost dates for.
    # @param [Date, nil] start_date Start date for frost dates data.
    # @param [Date, nil] end_date End date for frost dates data.
    # @return [Array<Reading>] Array of frost date readings.
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

    # Fetches daily climate time series data.
    #
    # @param [String] param Climate parameter type to retrieve
    # @param [String, nil] station_number Station number
    # @param [String, nil] site_id Site ID
    # @param [Date, nil] start_date Start date for time series data
    # @param [Date, nil] end_date End date for time series data
    # @return [Array<Reading>] Array of daily climate readings
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

    # Fetches monthly climate time series data.
    #
    # @param [String] param Climate parameter type to retrieve
    # @param [String, nil] station_number Station number
    # @param [String, nil] site_id Site ID
    # @param [Date, nil] start_date Start date for time series data
    # @param [Date, nil] end_date End date for time series data
    # @return [Array<Reading>] Array of monthly climate readings
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

    # Fetches climate time series data for specified stations.
    #
    # @param [String, nil] station_number Station number
    # @param [String, nil] site_id Site ID
    # @param [String] param Climate parameter to retrieve (Evap, FrostDate, MaxTemp, etc.)
    # @param [Date, nil] start_date Start date for time series data
    # @param [Date, nil] end_date End date for time series data
    # @param [String] timescale Time interval for data aggregation ('day' or 'month'). Defaults to 'day'
    # @return [Array<Reading>] Array of time series reading objects
    # @raise [ArgumentError] If an invalid parameter or timescale is provided
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
