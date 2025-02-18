module Cdss
  # Provides access to reference tables from the CDSS API.
  # These tables provide metadata and lookup information for various CDSS resources.
  module ReferenceTables
    include Utils

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
    # @return [Array<Cdss::Models::ReferenceTable>] Array of reference table records.
    # @raise [ArgumentError] If an invalid table name is provided.
    def get_reference_table(table_name, **params)
      validate_table_name!(table_name)
      method_name = "fetch_#{table_name}_reference"
      send(method_name, **params)
    end

    private

    def validate_table_name!(table_name)
      unless VALID_TABLES.include?(table_name)
        raise ArgumentError,
              "Invalid table_name: #{table_name}. Valid values are: #{VALID_TABLES.join(', ')}"
      end
    end

    def fetch_county_reference(county: nil)
      query = build_query({ county: county })
      fetch_reference_data("/referencetables/county/", query)
    end

    def fetch_waterdistricts_reference(division: nil, water_district: nil)
      query = build_query(
        {
          division: division,
          waterDistrict: water_district
        }
      )
      fetch_reference_data("/referencetables/waterdistrict/", query)
    end

    def fetch_waterdivisions_reference(division: nil)
      query = build_query({ division: division })
      fetch_reference_data("/referencetables/waterdivision/", query)
    end

    def fetch_managementdistricts_reference(management_district: nil)
      query = build_query({ managementDistrictName: management_district })
      fetch_reference_data("/referencetables/managementdistrict/", query)
    end

    def fetch_designatedbasins_reference(designated_basin: nil)
      query = build_query({ designatedBasinName: designated_basin })
      fetch_reference_data("/referencetables/designatedbasin/", query)
    end

    def fetch_telemetryparams_reference(param: nil)
      query = build_query({ parameter: param })
      fetch_reference_data("/referencetables/telemetryparams/", query)
    end

    def fetch_climateparams_reference(param: nil)
      query = build_query({ measType: param })
      fetch_reference_data("/referencetables/climatestationmeastype/", query)
    end

    def fetch_divrectypes_reference(divrectype: nil)
      query = build_query({ divRecType: divrectype })
      fetch_reference_data("/referencetables/divrectypes/", query)
    end

    def fetch_flags_reference(flag: nil)
      query = build_query({ flag: flag })
      fetch_reference_data("/referencetables/stationflags/", query)
    end

    def fetch_reference_data(endpoint, query)
      fetch_paginated_data(endpoint: endpoint, query: query) do |data|
        Parser.parse_reference_table(data)
      end
    end
  end
end
