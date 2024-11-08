module Cdss
  # Provides methods for accessing water rights data from the CDSS API.
  #
  # This module includes functionality for retrieving water rights net amounts
  # and transactions data based on various spatial and attribute-based searches.
  module WaterRights
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
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        units: 'miles'
      }

      query[:county] = county if county
      query[:division] = division if division
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
      end

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/waterrights/netamount/", {
          query: query
        })

        data = handle_response(response)
        rights = Parser.parse_water_rights(data, type: :net_amount)

        break if rights.empty?

        results.concat(rights)

        break if rights.size < page_size

        page_index += 1
      end

      results
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
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        units: 'miles'
      }

      query[:county] = county if county
      query[:division] = division if division
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
      end

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = get("/waterrights/transaction/", {
          query: query
        })

        data = handle_response(response)
        rights = Parser.parse_water_rights(data, type: :transaction)

        break if rights.empty?

        results.concat(rights)

        break if rights.size < page_size

        page_index += 1
      end

      results
    end
  end
end
