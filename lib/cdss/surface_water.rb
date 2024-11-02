module Cdss
  module SurfaceWater
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

        response = self.class.get("/surfacewater/surfacewaterstations/", {
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

        response = self.class.get("/surfacewater/surfacewatertsday/", {
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

        response = self.class.get("/surfacewater/surfacewatertsmonth/", {
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

        response = self.class.get("/surfacewater/surfacewatertswateryear/", {
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
