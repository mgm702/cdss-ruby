module Cdss
  # Provides methods for accessing surface water data from the CDSS API.
  #
  # This module includes functionality for retrieving surface water stations and their
  # associated time series data at various time scales (daily, monthly, yearly).
  module SurfaceWater
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
    def get_sw_stations(aoi: nil, radius: nil, abbrev: nil, county: nil, division: nil, station_name: nil, usgs_id: nil, water_district: nil, api_key: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      query[:abbrev] = abbrev if abbrev
      query[:county] = county if county
      query[:division] = division if division
      query[:stationName] = station_name if station_name
      query[:usgsSiteId] = usgs_id if usgs_id
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
        query[:units] = 'miles'
      end

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/surfacewater/surfacewaterstations/", {
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
    def get_sw_ts(abbrev: nil, station_number: nil, usgs_id: nil, start_date: nil, end_date: nil, timescale: nil, api_key: nil)
      timescale ||= 'day'

      day_lst = ['day', 'days', 'daily', 'd']
      month_lst = ['month', 'months', 'monthly', 'mon', 'm']
      year_lst = ['wyear', 'water_year', 'wyears', 'water_years', 'wateryear', 'wateryears', 'wy', 'year', 'years', 'yearly', 'annual', 'annually', 'yr', 'y']
      timescale_lst = day_lst + month_lst + year_lst

      unless timescale_lst.include?(timescale)
        valid_timescales = timescale_lst.join(', ')
        raise ArgumentError, "Invalid 'timescale' argument: '#{timescale}'. Valid values are: #{valid_timescales}"
      end

      case timescale
      when *day_lst
        get_sw_ts_day(abbrev: abbrev, station_number: station_number, usgs_id: usgs_id, start_date: start_date, end_date: end_date, api_key: api_key)
      when *month_lst
        get_sw_ts_month(abbrev: abbrev, station_number: station_number, usgs_id: usgs_id, start_date: start_date, end_date: end_date, api_key: api_key)
      when *year_lst
        get_sw_ts_wyear(abbrev: abbrev, station_number: station_number, usgs_id: usgs_id, start_date: start_date, end_date: end_date, api_key: api_key)
      else
        raise ArgumentError, "Invalid 'timescale' argument: '#{timescale}'"
      end
    end

    private

    # Fetches daily surface water time series data.
    #
    # @param [String, nil] abbrev Station abbreviation.
    # @param [String, nil] station_number Station number.
    # @param [String, nil] usgs_id USGS site ID.
    # @param [Date, nil] start_date Start date for time series data.
    # @param [Date, nil] end_date End date for time series data.
    # @param [String, nil] api_key Optional API key for authentication.
    # @return [Array<Reading>] Array of daily reading objects.
    def get_sw_ts_day(abbrev: nil, station_number: nil, usgs_id: nil, start_date: nil, end_date: nil, api_key: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      query[:abbrev] = abbrev if abbrev
      query[:stationNum] = station_number if station_number
      query[:usgsSiteId] = usgs_id if usgs_id
      query[:'min-measDate'] = start_date.strftime('%m-%d-%Y') if start_date
      query[:'max-measDate'] = end_date.strftime('%m-%d-%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/surfacewater/surfacewatertsday/", {
          query: query
        })

        data = handle_response(response)
        readings = Parser.parse_readings(data, timescale: :day)

        break if readings.empty?

        results.concat(readings)

        break if readings.size < page_size

        page_index += 1
      end

      results
    end

    # Fetches monthly surface water time series data.
    #
    # @param [String, nil] abbrev Station abbreviation.
    # @param [String, nil] station_number Station number.
    # @param [String, nil] usgs_id USGS site ID.
    # @param [Date, nil] start_date Start date for time series data (only year is used).
    # @param [Date, nil] end_date End date for time series data (only year is used).
    # @param [String, nil] api_key Optional API key for authentication.
    # @return [Array<Reading>] Array of monthly reading objects.
    def get_sw_ts_month(abbrev: nil, station_number: nil, usgs_id: nil, start_date: nil, end_date: nil, api_key: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      query[:abbrev] = abbrev if abbrev
      query[:stationNum] = station_number if station_number
      query[:usgsSiteId] = usgs_id if usgs_id
      query[:'min-calYear'] = start_date.strftime('%Y') if start_date
      query[:'max-calYear'] = end_date.strftime('%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/surfacewater/surfacewatertsmonth/", {
          query: query
        })

        data = handle_response(response)
        readings = Parser.parse_readings(data, timescale: :month)

        break if readings.empty?

        results.concat(readings)

        break if readings.size < page_size

        page_index += 1
      end

      results
    end

    # Fetches water year surface water time series data.
    #
    # @param [String, nil] abbrev Station abbreviation.
    # @param [String, nil] station_number Station number.
    # @param [String, nil] usgs_id USGS site ID.
    # @param [Date, nil] start_date Start date for time series data (only year is used).
    # @param [Date, nil] end_date End date for time series data (only year is used).
    # @param [String, nil] api_key Optional API key for authentication.
    # @return [Array<Reading>] Array of water year reading objects.
    def get_sw_ts_wyear(abbrev: nil, station_number: nil, usgs_id: nil, start_date: nil, end_date: nil, api_key: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      query[:abbrev] = abbrev if abbrev
      query[:stationNum] = station_number if station_number
      query[:usgsSiteId] = usgs_id if usgs_id
      query[:'min-waterYear'] = start_date.strftime('%Y') if start_date
      query[:'max-waterYear'] = end_date.strftime('%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/surfacewater/surfacewatertswateryear/", {
          query: query
        })

        data = handle_response(response)
        readings = Parser.parse_readings(data, timescale: :year)

        break if readings.empty?

        results.concat(readings)

        break if readings.size < page_size

        page_index += 1
      end

      results
    end
  end
end
