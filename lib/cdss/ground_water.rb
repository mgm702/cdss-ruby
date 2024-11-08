module Cdss
  module GroundWater
    # Fetches groundwater water level wells based on filters.
    #
    # @param [String, nil] county County to filter wells
    # @param [String, nil] designated_basin Designated basin to filter wells
    # @param [Integer, nil] division Division to filter wells
    # @param [String, nil] management_district Management district to filter wells
    # @param [Integer, nil] water_district Water district number to filter wells
    # @param [String, nil] wellid Well ID to filter specific well
    # @return [Array<Well>] An array of groundwater well objects
    # @example Fetch wells in Denver county
    #   client.get_water_level_wells(county: 'Denver')
    def get_water_level_wells(county: nil, designated_basin: nil, division: nil, management_district: nil, water_district: nil, wellid: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      query[:county] = county&.upcase&.gsub(' ', '+') if county
      query[:designatedBasin] = designated_basin&.upcase&.gsub(' ', '+') if designated_basin
      query[:division] = division if division
      query[:managementDistrict] = management_district&.upcase&.gsub(' ', '+') if management_district
      query[:waterDistrict] = water_district if water_district
      query[:wellId] = wellid if wellid

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/groundwater/waterlevels/wells/", {
          query: query
        })

        data = handle_response(response)
        wells = Parser.parse_wells(data)

        break if wells.empty?

        results.concat(wells)

        break if wells.size < page_size

        page_index += 1
      end

      results
    end

    # Fetches water level measurements for a specific well
    #
    # @param [String] wellid Well ID to fetch measurements for
    # @param [Date, nil] start_date Start date for the data range
    # @param [Date, nil] end_date End date for the data range
    # @return [Array<Reading>] An array of water level measurements
    # @example Fetch measurements for a specific well
    #   client.get_well_measurements(wellid: '1234', start_date: Date.parse('2021-01-01'))
    def get_well_measurements(wellid:, start_date: nil, end_date: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        wellId: wellid
      }

      query[:'min-measurementDate'] = start_date.strftime('%m-%d-%Y') if start_date
      query[:'max-measurementDate'] = end_date.strftime('%m-%d-%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/groundwater/waterlevels/wellmeasurements/", {
          query: query
        })

        data = handle_response(response)
        measurements = Parser.parse_well_measurements(data)

        break if measurements.empty?

        results.concat(measurements)

        break if measurements.size < page_size

        page_index += 1
      end

      results
    end

    # Fetches groundwater geophysical log wells based on filters
    #
    # @param [String, nil] county County to filter wells
    # @param [String, nil] designated_basin Designated basin to filter wells
    # @param [Integer, nil] division Division to filter wells
    # @param [String, nil] management_district Management district to filter wells
    # @param [Integer, nil] water_district Water district number to filter wells
    # @param [String, nil] wellid Well ID to filter specific well
    # @return [Array<Well>] An array of geophysical log well objects
    # @example Fetch geophysical log wells in Denver county
    #   client.get_geophysical_log_wells(county: 'Denver')
    def get_geophysical_log_wells(county: nil, designated_basin: nil, division: nil, management_district: nil, water_district: nil, wellid: nil)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      query[:county] = county&.upcase&.gsub(' ', '+') if county
      query[:designatedBasin] = designated_basin&.upcase&.gsub(' ', '+') if designated_basin
      query[:division] = division if division
      query[:managementDistrict] = management_district&.upcase&.gsub(' ', '+') if management_district
      query[:waterDistrict] = water_district if water_district
      query[:wellId] = wellid if wellid

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/groundwater/geophysicallogs/wells/", {
          query: query
        })

        data = handle_response(response)
        wells = Parser.parse_geophysical_wells(data)

        break if wells.empty?

        results.concat(wells)

        break if wells.size < page_size

        page_index += 1
      end

      results
    end

    # Fetches geophysical log picks for a specific well
    #
    # @param [String] wellid Well ID to fetch log picks for
    # @return [Array<LogPick>] An array of geophysical log pick objects
    # @raise [ArgumentError] if wellid is nil
    # @example Fetch log picks for a specific well
    #   client.get_geophysical_log_picks(wellid: '1234')
    def get_geophysical_log_picks(wellid:)
      raise ArgumentError, "wellid is required" if wellid.nil?

      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        wellId: wellid
      }

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/groundwater/geophysicallogs/geoplogpicks/", {
          query: query
        })

        data = handle_response(response)
        picks = Parser.parse_log_picks(data)

        break if picks.empty?

        results.concat(picks)

        break if picks.size < page_size

        page_index += 1
      end

      results
    end
  end
end
