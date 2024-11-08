module Cdss
  module Telemetry
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
        includeThirdParty: true
      }

      query[:abbrev] = abbrev if abbrev
      query[:county] = county if county
      query[:division] = division if division
      query[:gnisId] = gnis_id if gnis_id
      query[:usgsStationId] = usgs_id if usgs_id
      query[:waterDistrict] = water_district if water_district
      query[:wdid] = wdid if wdid

      if aoi
        if aoi.is_a?(Hash) && aoi[:latitude] && aoi[:longitude]
          query[:longitude] = aoi[:longitude]
          query[:latitude] = aoi[:latitude]
        elsif aoi.is_a?(Array) && aoi.count == 2
          query[:longitude] = aoi[0]
          query[:latitude] = aoi[1]
        else
          raise ArgumentError, "Invalid 'aoi' parameter"
        end
        query[:radius] = radius || 20
        query[:units] = 'miles'
      end

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/telemetrystations/telemetrystation/", {
          query: query
        })

        data = handle_response(response)
        stations = Parser.parse_stations(data)

        break if stations.empty?

        results.concat(stations)

        break if stations.size < page_size

        page_index += 1
      end

      results
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

      query[:startDate] = start_date.strftime('%m-%d-%Y') if start_date
      query[:endDate] = end_date.strftime('%m-%d-%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/telemetrystations/telemetrytimeseries#{timescale}/", {
          query: query
        })

        data = handle_response(response)
        readings = Parser.parse_readings(data, timescale: timescale.to_sym)

        break if readings.empty?

        results.concat(readings)

        break if readings.size < page_size

        page_index += 1
      end

      results
    end
  end
end
