# frozen_string_literal: true

module Cdss
  # Provides methods for accessing administrative calls data from the CDSS API.
  #
  # This module includes functionality for retrieving active and historical administrative
  # calls based on various criteria such as division, location, and date ranges.
  module AdminCalls
    include Utils

    # Fetches administrative calls based on various filtering criteria.
    #
    # @param [Integer, nil] division Water division to filter calls.
    # @param [String, nil] location_wdid WDID of the call location structure.
    # @param [Integer, nil] call_number Unique call identifier to query.
    # @param [Date, nil] start_date Start date for calls data.
    # @param [Date, nil] end_date End date for calls data.
    # @param [Boolean] active Whether to fetch active (true) or historical (false) calls. Defaults to true.
    # @return [Array<AdminCall>] Array of matching administrative call objects.
    # @example Fetch active calls for a division
    #   get_admin_calls(division: 1, active: true)
    def get_admin_calls(division: nil, location_wdid: nil, call_number: nil, start_date: nil, end_date: nil,
                        active: true)
      query = build_query(
        {
          dateFormat: "spaceSepToSeconds",
          division: division,
          callNumber: call_number,
          "min-dateTimeSet": format_date(start_date),
          "max-dateTimeSet": format_date(end_date),
          locationWdid: location_wdid
        },
        encode: true
      )

      endpoint = active ? "administrativecalls/active/" : "administrativecalls/historical/"

      fetch_paginated_data(
        endpoint: "/#{endpoint}",
        query: query
      ) { |data| Parser.parse_admin_calls(data) }
    end
  end
end
