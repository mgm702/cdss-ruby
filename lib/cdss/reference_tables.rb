# frozen_string_literal: true

module Cdss
  # Provides access to reference tables from the CDSS API.
  # These tables provide metadata and lookup information for various CDSS resources.
  module ReferenceTables
    include Utils

    # List of valid reference table names that can be queried
    VALID_TABLES = %w[
      county
      waterdistricts
      waterdivisions
      designatedbasins
      managementdistricts
      telemetryparams
      climateparams
      divrectypes
      flags
    ].freeze

    # Fetches reference table data from the CDSS API.
    #
    # @param [String] table_name The name of the reference table to fetch.
    #   Must be one of: county, waterdistricts, waterdivisions, designatedbasins,
    #   managementdistricts, telemetryparams, climateparams, divrectypes, flags
    # @param [Hash] params Additional parameters for filtering table data
    # @return [Array<Cdss::Models::ReferenceTable>] Array of reference table records
    # @raise [ArgumentError] If an invalid table name is provided
    def get_reference_table(table_name, **params)
      validate_table_name!(table_name)
      method_name = "fetch_#{table_name}_reference"
      send(method_name, **params)
    end

    private

    # Validates that the requested table name is supported.
    #
    # @param [String] table_name Name of table to validate
    # @raise [ArgumentError] If table_name is not in VALID_TABLES list
    def validate_table_name!(table_name)
      return if VALID_TABLES.include?(table_name)

      raise ArgumentError,
            "Invalid table_name: #{table_name}. Valid values are: #{VALID_TABLES.join(', ')}"
    end

    # Fetches county reference data.
    #
    # @param [String, nil] county County name to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of county records
    def fetch_county_reference(county: nil)
      query = build_query({ county: county })
      fetch_reference_data("/referencetables/county/", query)
    end

    # Fetches water district reference data.
    #
    # @param [Integer, nil] division Division to filter by
    # @param [Integer, nil] water_district Water district to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of water district records
    def fetch_waterdistricts_reference(division: nil, water_district: nil)
      query = build_query(
        {
          division: division,
          waterDistrict: water_district
        }
      )
      fetch_reference_data("/referencetables/waterdistrict/", query)
    end

    # Fetches water division reference data.
    #
    # @param [Integer, nil] division Division to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of water division records
    def fetch_waterdivisions_reference(division: nil)
      query = build_query({ division: division })
      fetch_reference_data("/referencetables/waterdivision/", query)
    end

    # Fetches management district reference data.
    #
    # @param [String, nil] management_district Management district name to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of management district records
    def fetch_managementdistricts_reference(management_district: nil)
      query = build_query({ managementDistrictName: management_district })
      fetch_reference_data("/referencetables/managementdistrict/", query)
    end

    # Fetches designated basin reference data.
    #
    # @param [String, nil] designated_basin Designated basin name to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of designated basin records
    def fetch_designatedbasins_reference(designated_basin: nil)
      query = build_query({ designatedBasinName: designated_basin })
      fetch_reference_data("/referencetables/designatedbasin/", query)
    end

    # Fetches telemetry parameter reference data.
    #
    # @param [String, nil] param Parameter name to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of telemetry parameter records
    def fetch_telemetryparams_reference(param: nil)
      query = build_query({ parameter: param })
      fetch_reference_data("/referencetables/telemetryparams/", query)
    end

    # Fetches climate parameter reference data.
    #
    # @param [String, nil] param Climate parameter type to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of climate parameter records
    def fetch_climateparams_reference(param: nil)
      query = build_query({ measType: param })
      fetch_reference_data("/referencetables/climatestationmeastype/", query)
    end

    # Fetches diversion record type reference data.
    #
    # @param [String, nil] divrectype Record type to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of diversion record type records
    def fetch_divrectypes_reference(divrectype: nil)
      query = build_query({ divRecType: divrectype })
      fetch_reference_data("/referencetables/divrectypes/", query)
    end

    # Fetches station flag reference data.
    #
    # @param [String, nil] flag Flag to filter by
    # @return [Array<Cdss::Models::ReferenceTable>] Array of station flag records
    def fetch_flags_reference(flag: nil)
      query = build_query({ flag: flag })
      fetch_reference_data("/referencetables/stationflags/", query)
    end

    # Fetches and parses reference table data from an endpoint.
    #
    # @param [String] endpoint API endpoint path
    # @param [Hash] query Query parameters for the request
    # @return [Array<Cdss::Models::ReferenceTable>] Array of reference table records
    def fetch_reference_data(endpoint, query)
      fetch_paginated_data(endpoint: endpoint, query: query) do |data|
        Parser.parse_reference_table(data)
      end
    end
  end
end
