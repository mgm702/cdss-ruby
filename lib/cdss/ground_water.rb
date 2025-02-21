# frozen_string_literal: true

module Cdss
  module GroundWater
    include Utils

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
    def get_water_level_wells(county: nil, designated_basin: nil, division: nil, management_district: nil,
                              water_district: nil, wellid: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        county: county&.upcase&.gsub(" ", "+"),
        designatedBasin: designated_basin&.upcase&.gsub(" ", "+"),
        division: division,
        managementDistrict: management_district&.upcase&.gsub(" ", "+"),
        waterDistrict: water_district,
        wellId: wellid
      }

      fetch_paginated_data(
        endpoint: "/groundwater/waterlevels/wells/",
        query: query
      ) { |data| Parser.parse_wells(data) }
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
        format: "json",
        dateFormat: "spaceSepToSeconds",
        wellId: wellid,
        "min-measurementDate": start_date&.strftime("%m-%d-%Y"),
        "max-measurementDate": end_date&.strftime("%m-%d-%Y")
      }

      fetch_paginated_data(
        endpoint: "/groundwater/waterlevels/wellmeasurements/",
        query: query
      ) { |data| Parser.parse_well_measurements(data) }
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
    def get_geophysical_log_wells(county: nil, designated_basin: nil, division: nil, management_district: nil,
                                  water_district: nil, wellid: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        county: county&.upcase&.gsub(" ", "+"),
        designatedBasin: designated_basin&.upcase&.gsub(" ", "+"),
        division: division,
        managementDistrict: management_district&.upcase&.gsub(" ", "+"),
        waterDistrict: water_district,
        wellId: wellid
      }

      fetch_paginated_data(
        endpoint: "/groundwater/geophysicallogs/wells/",
        query: query
      ) { |data| Parser.parse_geophysical_wells(data) }
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
        format: "json",
        dateFormat: "spaceSepToSeconds",
        wellId: wellid
      }

      fetch_paginated_data(
        endpoint: "/groundwater/geophysicallogs/geoplogpicks/",
        query: query
      ) { |data| Parser.parse_log_picks(data) }
    end
  end
end
