# frozen_string_literal: true

module Cdss
  # Provides methods for accessing water rights data from the CDSS API.
  #
  # This module includes functionality for retrieving water rights net amounts
  # and transactions data based on various spatial and attribute-based searches.
  module WaterRights
    include Utils

    # Fetches water rights net amounts data based on various filtering criteria.
    #
    # @param [Hash, Array, nil] aoi Area of interest for spatial searches. If hash, must contain :latitude and :longitude keys.
    #   If array, must contain [longitude, latitude].
    # @param [Integer, nil] radius Radius in miles for spatial search around aoi. Defaults to 20 if aoi is provided.
    # @param [String, nil] county County name to filter rights.
    # @param [Integer, nil] division Water division number to filter rights.
    # @param [Integer, nil] water_district Water district number to filter rights.
    # @param [String, nil] wdid WDID code of water right.
    # @return [Array<WaterRight>] Array of water right objects with net amounts.
    # @raise [ArgumentError] If aoi parameter is provided but invalid.
    def get_water_rights_net_amounts(aoi: nil, radius: nil, county: nil, division: nil, water_district: nil, wdid: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        units: "miles",
        county: county,
        division: division,
        waterDistrict: water_district,
        wdid: wdid
      }

      query.merge!(process_aoi(aoi, radius)) if aoi

      fetch_paginated_data(
        endpoint: "/waterrights/netamount/",
        query: query
      ) { |data| Parser.parse_water_rights(data, type: :net_amount) }
    end

    # Fetches water rights transactions data based on various filtering criteria.
    #
    # @param [Hash, Array, nil] aoi Area of interest for spatial searches. If hash, must contain :latitude and :longitude keys.
    #   If array, must contain [longitude, latitude].
    # @param [Integer, nil] radius Radius in miles for spatial search around aoi. Defaults to 20 if aoi is provided.
    # @param [String, nil] county County name to filter transactions.
    # @param [Integer, nil] division Water division number to filter transactions.
    # @param [Integer, nil] water_district Water district number to filter transactions.
    # @param [String, nil] wdid WDID code of water right.
    # @return [Array<WaterRight>] Array of water right objects with transactions.
    # @raise [ArgumentError] If aoi parameter is provided but invalid.
    def get_water_rights_transactions(aoi: nil, radius: nil, county: nil, division: nil, water_district: nil, wdid: nil)
      query = {
        format: "json",
        dateFormat: "spaceSepToSeconds",
        units: "miles",
        county: county,
        division: division,
        waterDistrict: water_district,
        wdid: wdid
      }

      query.merge!(process_aoi(aoi, radius)) if aoi

      fetch_paginated_data(
        endpoint: "/waterrights/transaction/",
        query: query
      ) { |data| Parser.parse_water_rights(data, type: :transaction) }
    end

    private

    def process_aoi(aoi, radius)
      if aoi.is_a?(Hash) && aoi[:latitude] && aoi[:longitude]
        {
          longitude: aoi[:longitude],
          latitude: aoi[:latitude],
          radius: radius || 20
        }
      elsif aoi.is_a?(Array) && aoi.count == 2
        {
          longitude: aoi[0],
          latitude: aoi[1],
          radius: radius || 20
        }
      else
        raise ArgumentError, "Invalid 'aoi' parameter"
      end
    end
  end
end
