module Cdss
  # Provides methods for accessing climate data from the CDSS API.
  #
  # This module includes functionality for retrieving climate stations, frost dates,
  # and time series data at various time scales (daily, monthly).
  module Climate
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
    # @return [Array<ClimateStation>] Array of matching climate station objects.
    # @raise [ArgumentError] If aoi parameter is provided but invalid.
    def get_climate_stations(aoi: nil, radius: nil, county: nil, division: nil, station_name: nil, site_id: nil, water_district: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        units: 'miles'
      }

      query[:county] = county if county
      query[:division] = division if division
      query[:stationName] = station_name if station_name
      query[:siteId] = Array(site_id).join('%2C+') if site_id
      query[:waterDistrict] = water_district if water_district

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
      end

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/climatedata/climatestations/", {
          query: query
        })

        data = handle_response(response)
        stations = Parser.parse_climate_stations(data)

        break if stations.empty?

        results.concat(stations)

        break if stations.size < page_size

        page_index += 1
      end

      results
    end

    # Fetches frost dates for a specific climate station.
    #
    # @param [String] station_number Station number to fetch frost dates for.
    # @param [Date, nil] start_date Start date for frost dates data.
    # @param [Date, nil] end_date End date for frost dates data.
    # @return [Array<Reading>] Array of frost date readings.
    def get_climate_frost_dates(station_number:, start_date: nil, end_date: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        stationNum: station_number
      }

      query[:'min-calYear'] = start_date.strftime('%Y') if start_date
      query[:'max-calYear'] = end_date.strftime('%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/climatedata/climatestationfrostdates/", {
          query: query
        })

        data = handle_response(response)
        readings = Parser.parse_climate_readings(data, type: :frost_dates)

        break if readings.empty?

        results.concat(readings)

        break if readings.size < page_size

        page_index += 1
      end

      results
    end

    # Fetches climate time series data for specified stations.
    #
    # @param [String, nil] station_number Station number.
    # @param [String, Array<String>, nil] site_id Site ID or array of site IDs.
    # @param [String] param Climate parameter to retrieve (Evap, FrostDate, MaxTemp, etc.).
    # @param [Date, nil] start_date Start date for time series data.
    # @param [Date, nil] end_date End date for time series data.
    # @param [String, nil] timescale Time interval for data ('day' or 'month'). Defaults to 'day'.
    # @return [Array<Reading>] Array of climate reading objects.
    # @raise [ArgumentError] If an invalid parameter or timescale is provided.
    def get_climate_ts(station_number: nil, site_id: nil, param:, start_date: nil, end_date: nil, timescale: 'day')
      valid_params = %w[Evap FrostDate MaxTemp MeanTemp MinTemp Precip Snow SnowDepth SnowSWE Solar VP Wind]
      unless valid_params.include?(param)
        raise ArgumentError, "Invalid parameter: '#{param}'. Valid values are: #{valid_params.join(', ')}"
      end

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

    private

    def get_climate_ts_day(station_number: nil, site_id: nil, param:, start_date: nil, end_date: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        measType: param
      }

      query[:stationNum] = station_number if station_number
      query[:siteId] = Array(site_id).join('%2C+') if site_id
      query[:'min-measDate'] = start_date.strftime('%m-%d-%Y') if start_date
      query[:'max-measDate'] = end_date.strftime('%m-%d-%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/climatedata/climatestationtsday/", {
          query: query
        })

        data = handle_response(response)
        readings = Parser.parse_climate_readings(data, type: :daily)

        break if readings.empty?

        results.concat(readings)

        break if readings.size < page_size

        page_index += 1
      end

      results
    end

    def get_climate_ts_month(station_number: nil, site_id: nil, param:, start_date: nil, end_date: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        measType: param
      }

      query[:stationNum] = station_number if station_number
      query[:siteId] = Array(site_id).join('%2C+') if site_id
      query[:'min-calYear'] = start_date.strftime('%Y') if start_date
      query[:'max-calYear'] = end_date.strftime('%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/climatedata/climatestationtsmonth/", {
          query: query
        })

        data = handle_response(response)
        readings = Parser.parse_climate_readings(data, type: :monthly)

        break if readings.empty?

        results.concat(readings)

        break if readings.size < page_size

        page_index += 1
      end

      results
    end
  end
end
