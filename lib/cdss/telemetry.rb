module Cdss
  module Telemetry
    include Utils

    # Fetches telemetry station data based on filters.
    #
    # This method allows querying telemetry stations by various attributes,
    # such as abbreviation, county, division, and more. Results are paginated
    # and merged into a single array.
    #
    # @param [Hash, Array, nil] aoi An area of interest for spatial searches.
    #   If a hash is provided, it must have keys `:latitude` and `:longitude`.
    #   If an array is provided, it must contain two elements in the order [latitude, longitude].
    # @param [Integer, nil] radius Radius in miles for spatial search around `aoi`. Defaults to 20 miles if `aoi` is provided.
    # @param [String, nil] abbrev Abbreviation of the telemetry station.
    # @param [String, nil] county County name to filter stations.
    # @param [Integer, nil] division Water division number to filter stations.
    # @param [String, nil] gnis_id GNIS ID of the station.
    # @param [String, nil] usgs_id USGS ID of the station.
    # @param [Integer, nil] water_district Water district number.
    # @param [String, nil] wdid WDID of the telemetry station.
    # @return [Array<Station>] An array of telemetry station objects.
    # @raise [ArgumentError] if the `aoi` parameter is provided but not in the correct format.
    # @example Usage
    #   client.get_telemetry_stations(abbrev: 'PLACHECO', county: 'Denver')
    def get_telemetry_stations(aoi: nil, radius: nil, abbrev: nil, county: nil, division: nil, gnis_id: nil, usgs_id: nil, water_district: nil, wdid: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
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
        query[:units] = 'miles'
      end

      fetch_paginated_data(
        endpoint: "/telemetrystations/telemetrystation/",
        query: query
      ) { |data| Parser.parse_stations(data) }
    end

    # Fetches telemetry time series data for a specific station.
    #
    # This method retrieves time series data for a station by abbreviation,
    # within a specified date range and time scale (e.g., daily, hourly).
    #
    # @param [String] abbrev Station abbreviation.
    # @param [String] parameter Telemetry parameter to retrieve. Default is `'DISCHRG'`.
    # @param [Date, nil] start_date Start date for the data range. Defaults to `nil`, which retrieves from the earliest available date.
    # @param [Date, nil] end_date End date for the data range. Defaults to `nil`, which retrieves until the latest available date.
    # @param [String] timescale Time scale for the data, options are `'day'`, `'hour'`, or `'raw'`. Defaults to `'day'`.
    # @param [Boolean] include_third_party Whether to include third-party data. Defaults to `true`.
    # @return [Array<Reading>] An array of telemetry readings.
    # @raise [ArgumentError] if an invalid timescale is provided.
    # @example Fetch daily discharge data for the PLACHECO station
    #   client.get_telemetry_ts(abbrev: 'PLACHECO', parameter: 'DISCHRG', start_date: Date.parse('2021-01-01'), end_date: Date.parse('2021-12-31'))
    def get_telemetry_ts(abbrev:, parameter: 'DISCHRG', start_date: nil, end_date: nil, timescale: 'day', include_third_party: true)
      timescales = ['day', 'hour', 'raw']
      unless timescales.include?(timescale)
        raise ArgumentError, "Invalid 'timescale' argument: '#{timescale}'. Valid values are: #{timescales.join(', ')}"
      end

      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        abbrev: abbrev,
        parameter: parameter,
        includeThirdParty: include_third_party.to_s
      }

      query[:startDate] = start_date&.strftime('%m-%d-%Y') if start_date
      query[:endDate] = end_date&.strftime('%m-%d-%Y') if end_date

      fetch_paginated_data(
        endpoint: "/telemetrystations/telemetrytimeseries#{timescale}/",
        query: query
      ) { |data| Parser.parse_readings(data, timescale: timescale.to_sym) }
    end
  end
end
