# frozen_string_literal: true

module Cdss
  # Provides methods for accessing telemetry station data from the CDSS API.
  #
  # This module includes functionality for retrieving telemetry stations and their
  # associated time series data.
  module Telemetry
    include Utils

    # Fetches telemetry stations based on various filtering criteria.
    #
    # @param [Hash, Array, nil] aoi Area of interest for spatial searches. If hash, must contain :latitude and :longitude keys.
    #   If array, must contain [longitude, latitude].
    # @param [Integer, nil] radius Radius in miles for spatial search around aoi. Defaults to 20 if aoi is provided.
    # @param [String, nil] abbrev Station abbreviation to filter by.
    # @param [String, nil] county County name to filter stations.
    # @param [Integer, nil] division Water division number to filter stations.
    # @param [String, nil] gnis_id GNIS ID to filter by.
    # @param [String, nil] usgs_id USGS station ID to filter by.
    # @param [Integer, nil] water_district Water district number to filter by.
    # @param [String, nil] wdid WDID to filter by.
    # @return [Array<Station>] Array of matching telemetry station objects.
    # @raise [ArgumentError] If aoi parameter is provided but invalid.
    # @example Fetch stations in Denver county
    #   get_telemetry_stations(county: 'Denver')
    # @example Fetch stations within 10 miles of a point
    #   get_telemetry_stations(aoi: { latitude: 39.7392, longitude: -104.9903 }, radius: 10)
    def get_telemetry_stations(aoi: nil, radius: nil, abbrev: nil, county: nil, division: nil, gnis_id: nil,
                               usgs_id: nil, water_district: nil, wdid: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        includeThirdParty: true,
        abbrev: abbrev,
        county: county,
        division: division,
        gnisId: gnis_id,
        usgsStationId: usgs_id,
        waterDistrict: water_district,
        wdid: wdid
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
        endpoint: "/telemetrystations/telemetrystation/",
        query: query
      ) { |data| Parser.parse_stations(data) }
    end

    # Fetches telemetry time series data for specified stations.
    #
    # @param [String] abbrev Station abbreviation.
    # @param [String, nil] parameter Telemetry parameter to retrieve. Defaults to 'DISCHRG'.
    # @param [Date, nil] start_date Start date for time series data.
    # @param [Date, nil] end_date End date for time series data.
    # @param [String, nil] timescale Time interval for data. Valid values: 'day', 'hour', 'raw'.
    # @param [Boolean] include_third_party Whether to include third-party data. Defaults to true.
    # @return [Array<Reading>] Array of time series reading objects.
    # @raise [ArgumentError] If an invalid timescale is provided.
    # @example Fetch daily discharge data for a station
    #   get_telemetry_ts(abbrev: 'PLACHECO', parameter: 'DISCHRG', start_date: Date.new(2023, 1, 1))
    def get_telemetry_ts(abbrev:, parameter: "DISCHRG", start_date: nil, end_date: nil, timescale: "day",
                         include_third_party: true)
      timescales = %w[day hour raw]
      unless timescales.include?(timescale)
        raise ArgumentError, "Invalid 'timescale' argument: '#{timescale}'. Valid values are: #{timescales.join(', ')}"
      end

      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        abbrev: abbrev,
        parameter: parameter,
        includeThirdParty: include_third_party.to_s
      }

      query[:startDate] = start_date&.strftime("%m-%d-%Y") if start_date
      query[:endDate] = end_date&.strftime("%m-%d-%Y") if end_date

      fetch_paginated_data(
        endpoint: "/telemetrystations/telemetrytimeseries#{timescale}/",
        query: query
      ) { |data| Parser.parse_readings(data, timescale: timescale.to_sym) }
    end
  end
end
