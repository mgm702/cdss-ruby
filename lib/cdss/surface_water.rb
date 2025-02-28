# frozen_string_literal: true

module Cdss
  # Provides methods for accessing surface water data from the CDSS API.
  #
  # This module includes functionality for retrieving surface water stations and their
  # associated time series data at various time scales (daily, monthly, yearly).
  module SurfaceWater
    include Utils

    # Fetches surface water stations based on various filtering criteria.
    #
    # @param [Hash, Array, nil] aoi Area of interest for spatial searches. If hash, must contain :latitude and :longitude keys.
    #   If array, must contain [longitude, latitude].
    # @param [Integer, nil] radius Radius in miles for spatial search around aoi. Defaults to 20 if aoi is provided.
    # @param [String, nil] abbrev Station abbreviation to filter by.
    # @param [String, nil] county County name to filter stations.
    # @param [Integer, nil] division Water division number to filter stations.
    # @param [String, nil] station_name Name of the station to filter by.
    # @param [String, nil] usgs_id USGS site ID to filter by.
    # @param [Integer, nil] water_district Water district number to filter by.
    # @param [String, nil] api_key Optional API key for authentication.
    # @return [Array<Station>] Array of matching surface water station objects.
    # @raise [ArgumentError] If aoi parameter is provided but invalid.
    # @example Fetch stations in Denver county
    #   get_sw_stations(county: 'DENVER')
    # @example Fetch stations within 10 miles of a point
    #   get_sw_stations(aoi: { latitude: 39.7392, longitude: -104.9903 }, radius: 10)
    def get_sw_stations(aoi: nil, radius: nil, abbrev: nil, county: nil, division: nil, station_name: nil,
                        usgs_id: nil, water_district: nil, api_key: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        abbrev: abbrev,
        county: county,
        division: division,
        stationName: station_name,
        usgsSiteId: usgs_id,
        waterDistrict: water_district
      }

      if aoi
        if aoi.is_a?(Hash) && aoi[:latitude] && aoi[:longitude]
          query.merge!(longitude: aoi[:longitude], latitude: aoi[:latitude])
        elsif aoi.is_a?(Array) && aoi.count == 2
          query.merge!(longitude: aoi[0], latitude: aoi[1])
        else
          raise ArgumentError, "Invalid 'aoi' parameter"
        end
        query[:radius] = radius || 20
        query[:units] = "miles"
      end

      fetch_paginated_data(
        endpoint: "/surfacewater/surfacewaterstations/",
        query: query
      ) { |data| Parser.parse_stations(data) }
    end

    # Fetches surface water time series data for specified stations.
    #
    # @param [String, nil] abbrev Station abbreviation.
    # @param [String, nil] station_number Station number.
    # @param [String, nil] usgs_id USGS site ID.
    # @param [Date, nil] start_date Start date for time series data.
    # @param [Date, nil] end_date End date for time series data.
    # @param [String, nil] timescale Time interval for data aggregation. Valid values:
    #   - day, days, daily, d
    #   - month, months, monthly, mon, m
    #   - wyear, water_year, wyears, water_years, wateryear, wateryears, wy, year, years, yearly, annual, annually, yr, y
    # @param [String, nil] api_key Optional API key for authentication.
    # @return [Array<Reading>] Array of time series reading objects.
    # @raise [ArgumentError] If an invalid timescale is provided.
    # @example Fetch daily readings for a station
    #   get_sw_ts(abbrev: 'PLAKERCO', timescale: 'day', start_date: Date.new(2023, 1, 1))
    def get_sw_ts(abbrev: nil, station_number: nil, usgs_id: nil, start_date: nil, end_date: nil, timescale: nil,
                  api_key: nil)
      timescale ||= "day"

      day_lst = %w[day days daily d]
      month_lst = %w[month months monthly mon m]
      year_lst = %w[wyear water_year wyears water_years wateryear wateryears wy year years
                    yearly annual annually yr y]
      timescale_lst = day_lst + month_lst + year_lst

      unless timescale_lst.include?(timescale)
        valid_timescales = timescale_lst.join(", ")
        raise ArgumentError, "Invalid 'timescale' argument: '#{timescale}'. Valid values are: #{valid_timescales}"
      end

      case timescale
      when *day_lst
        get_sw_ts_day(abbrev: abbrev, station_number: station_number, usgs_id: usgs_id, start_date: start_date,
                      end_date: end_date, api_key: api_key)
      when *month_lst
        get_sw_ts_month(abbrev: abbrev, station_number: station_number, usgs_id: usgs_id, start_date: start_date,
                        end_date: end_date, api_key: api_key)
      when *year_lst
        get_sw_ts_wyear(abbrev: abbrev, station_number: station_number, usgs_id: usgs_id, start_date: start_date,
                        end_date: end_date, api_key: api_key)
      else
        raise ArgumentError, "Invalid 'timescale' argument: '#{timescale}'"
      end
    end

    private

    # Fetches daily surface water time series readings.
    #
    # @param [String, nil] abbrev Station abbreviation
    # @param [String, nil] station_number Station number
    # @param [String, nil] usgs_id USGS site ID
    # @param [Date, nil] start_date Start date for readings
    # @param [Date, nil] end_date End date for readings
    # @param [String, nil] api_key Optional API key for authentication
    # @return [Array<Reading>] Array of daily surface water readings
    def get_sw_ts_day(abbrev: nil, station_number: nil, usgs_id: nil, start_date: nil, end_date: nil, api_key: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        abbrev: abbrev,
        stationNum: station_number,
        usgsSiteId: usgs_id,
        "min-measDate": start_date&.strftime("%m-%d-%Y"),
        "max-measDate": end_date&.strftime("%m-%d-%Y")
      }

      fetch_paginated_data(
        endpoint: "/surfacewater/surfacewatertsday/",
        query: query
      ) { |data| Parser.parse_readings(data, timescale: :day) }
    end

    # Fetches monthly surface water time series readings.
    #
    # @param [String, nil] abbrev Station abbreviation
    # @param [String, nil] station_number Station number
    # @param [String, nil] usgs_id USGS site ID
    # @param [Date, nil] start_date Start date for readings (year only)
    # @param [Date, nil] end_date End date for readings (year only)
    # @param [String, nil] api_key Optional API key for authentication
    # @return [Array<Reading>] Array of monthly surface water readings
    def get_sw_ts_month(abbrev: nil, station_number: nil, usgs_id: nil, start_date: nil, end_date: nil, api_key: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        abbrev: abbrev,
        stationNum: station_number,
        usgsSiteId: usgs_id,
        "min-calYear": start_date&.strftime("%Y"),
        "max-calYear": end_date&.strftime("%Y")
      }

      fetch_paginated_data(
        endpoint: "/surfacewater/surfacewatertsmonth/",
        query: query
      ) { |data| Parser.parse_readings(data, timescale: :month) }
    end

    # Fetches water year time series readings.
    #
    # @param [String, nil] abbrev Station abbreviation
    # @param [String, nil] station_number Station number
    # @param [String, nil] usgs_id USGS site ID
    # @param [Date, nil] start_date Start date for readings (year only)
    # @param [Date, nil] end_date End date for readings (year only)
    # @param [String, nil] api_key Optional API key for authentication
    # @return [Array<Reading>] Array of water year readings
    def get_sw_ts_wyear(abbrev: nil, station_number: nil, usgs_id: nil, start_date: nil, end_date: nil, api_key: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        abbrev: abbrev,
        stationNum: station_number,
        usgsSiteId: usgs_id,
        "min-waterYear": start_date&.strftime("%Y"),
        "max-waterYear": end_date&.strftime("%Y")
      }

      fetch_paginated_data(
        endpoint: "/surfacewater/surfacewatertswateryear/",
        query: query
      ) { |data| Parser.parse_readings(data, timescale: :year) }
    end
  end
end
