require_relative 'utils'

module Cdss
  module Structures
    include Utils

    # Fetches a list of administrative structures based on various filtering criteria.
    #
    # @param [Hash, Array, nil] aoi Area of interest for spatial searches. If hash, must contain :latitude and :longitude keys.
    # @param [Integer, nil] radius Radius in miles for spatial search around aoi. Defaults to 20 if aoi is provided.
    # @param [String, nil] county County to filter structures.
    # @param [Integer, nil] division Water division to filter structures.
    # @param [String, nil] gnis_id GNIS ID to filter structures.
    # @param [Integer, nil] water_district Water district to filter structures.
    # @param [String, Array<String>, nil] wdid WDID code(s) to filter specific structures.
    # @return [Array<Models::Structure>] Array of matching structures.
    def get_structures(aoi: nil, radius: nil, county: nil, division: nil, gnis_id: nil, water_district: nil, wdid: nil)
      query = build_query({
        county: county,
        division: division,
        gnisId: gnis_id,
        waterDistrict: water_district,
        wdid: Array(wdid).join('%2C+'),
        units: 'miles'
      })

      if aoi
        coords = process_aoi(aoi)
        query.merge!({
          latitude: coords[:lat],
          longitude: coords[:lng],
          radius: radius || 20
        })
      end

      fetch_paginated_data(
        endpoint: "/structures/",
        query: query
      ) do |data|
        Parser.parse_structures(data)
      end
    end

    # Fetches diversion records time series data.
    #
    # @param [String, Array<String>] wdid WDID code(s) of structures.
    # @param [String, nil] wc_identifier Water class identifier.
    # @param [Date, nil] start_date Start date for time series data.
    # @param [Date, nil] end_date End date for time series data.
    # @param [String, nil] timescale Time interval ('day', 'month', or 'year'). Defaults to 'day'.
    # @return [Array<Models::DiversionRecord>] Array of diversion records.
    def get_diversion_records_ts(wdid:, wc_identifier: nil, start_date: nil, end_date: nil, timescale: 'day')
      validate_timescale!(timescale)

      method_name = "fetch_diversion_records_#{timescale}"
      send(method_name, wdid: wdid, wc_identifier: wc_identifier, start_date: start_date, end_date: end_date)
    end

    # Fetches stage/volume record data.
    #
    # @param [String] wdid WDID code of structure.
    # @param [Date, nil] start_date Start date for records.
    # @param [Date, nil] end_date End date for records.
    # @return [Array<Models::DiversionRecord>] Array of stage/volume records.
    def get_stage_volume_ts(wdid:, start_date: nil, end_date: nil)
      query = build_query({
        wdid: wdid,
        'min-dataMeasDate': format_date(start_date),
        'max-dataMeasDate': format_date(end_date)
      })

      fetch_paginated_data(
        endpoint: "/structures/divrec/stagevolume/",
        query: query
      ) do |data|
        Parser.parse_diversion_records(data, type: :stage_volume)
      end
    end

    # Fetches water classes for structures.
    #
    # @param [Hash] params Query parameters including wdid, county, division, etc.
    # @return [Array<Models::WaterClass>] Array of water classes.
    def get_water_classes(**params)
      query = build_query({
        wdid: Array(params[:wdid]).join('%2C+'),
        county: params[:county],
        division: params[:division],
        waterDistrict: params[:water_district],
        wcIdentifier: format_wc_identifier(params[:wc_identifier]),
        timestep: params[:timestep],
        'min-porStart': format_date(params[:start_date]),
        'min-porEnd': format_date(params[:end_date]),
        divrectype: params[:divrectype],
        ciuCode: params[:ciu_code],
        gnisId: params[:gnis_id]
      })

      if params[:aoi]
        coords = process_aoi(params[:aoi])
        query.merge!({
          latitude: coords[:lat],
          longitude: coords[:lng],
          radius: params[:radius] || 20,
          units: 'miles'
        })
      end

      fetch_paginated_data(
        endpoint: "/structures/divrec/waterclasses/",
        query: query
      ) do |data|
        Parser.parse_water_classes(data)
      end
    end

    private

    def validate_timescale!(timescale)
      valid_timescales = {
        'day' => %w[day days daily d],
        'month' => %w[month months monthly mon m],
        'year' => %w[year years yearly annual annually yr y]
      }

      normalized = timescale.to_s.downcase
      return if valid_timescales.values.flatten.include?(normalized)

      raise ArgumentError, "Invalid timescale: #{timescale}. Valid values are: #{valid_timescales.values.flatten.join(', ')}"
    end

    def format_wc_identifier(identifier)
      return '*diversion*' if identifier.nil?
      return 'diversion' if %w[diversion diversions div divs d].include?(identifier.downcase)
      return 'release' if %w[release releases rel rels r].include?(identifier.downcase)
      "*#{identifier}*"
    end

    def fetch_diversion_records_day(wdid:, wc_identifier:, start_date:, end_date:)
      query = build_diversion_query(wdid, wc_identifier, start_date, end_date)
      fetch_paginated_data(
        endpoint: "/structures/divrec/divrecday/",
        query: query
      ) do |data|
        Parser.parse_diversion_records(data, type: :day)
      end
    end

    def fetch_diversion_records_month(wdid:, wc_identifier:, start_date:, end_date:)
      query = build_diversion_query(wdid, wc_identifier, start_date, end_date)
      fetch_paginated_data(
        endpoint: "/structures/divrec/divrecmonth/",
        query: query
      ) do |data|
        Parser.parse_diversion_records(data, type: :month)
      end
    end

    def fetch_diversion_records_year(wdid:, wc_identifier:, start_date:, end_date:)
      query = build_diversion_query(wdid, wc_identifier, start_date, end_date)
      fetch_paginated_data(
        endpoint: "/structures/divrec/divrecyear/",
        query: query
      ) do |data|
        Parser.parse_diversion_records(data, type: :year)
      end
    end

    def build_diversion_query(wdid, wc_identifier, start_date, end_date)
      build_query({
        wdid: Array(wdid).join('%2C+'),
        wcIdentifier: format_wc_identifier(wc_identifier),
        'min-dataMeasDate': format_date(start_date),
        'max-dataMeasDate': format_date(end_date)
      })
    end
  end
end
