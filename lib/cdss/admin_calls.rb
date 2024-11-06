module Cdss
  # Provides methods for accessing administrative calls data from the CDSS API.
  #
  # This module includes functionality for retrieving active and historical administrative
  # calls based on various criteria such as division, location, and date ranges.
  module AdminCalls
    # Fetches administrative calls based on various filtering criteria.
    #
    # @param [Integer, nil] division Water division to filter calls.
    # @param [String, Array<String>, nil] location_wdid WDID of the call location structure.
    # @param [Integer, nil] call_number Unique call identifier to query.
    # @param [Date, nil] start_date Start date for calls data.
    # @param [Date, nil] end_date End date for calls data.
    # @param [Boolean] active Whether to fetch active (true) or historical (false) calls. Defaults to true.
    # @return [Array<AdminCall>] Array of matching administrative call objects.
    # @example Fetch active calls for a division
    #   get_admin_calls(division: 1, active: true)
    def get_admin_calls(division: nil, location_wdid: nil, call_number: nil, start_date: nil, end_date: nil, active: true)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      query[:division] = division if division
      query[:callNumber] = call_number if call_number
      query[:'min-dateTimeSet'] = start_date.strftime('%m-%d-%Y') if start_date
      query[:'max-dateTimeSet'] = end_date.strftime('%m-%d-%Y') if end_date

      if location_wdid
        query[:locationWdid] = Array(location_wdid).join('%2C+')
      end

      endpoint = active ? "administrativecalls/active/" : "administrativecalls/historical/"
      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/#{endpoint}", {
          query: query
        })

        data = handle_response(response)
        calls = Parser.parse_admin_calls(data)

        break if calls.empty?

        results.concat(calls)

        break if calls.size < page_size

        page_index += 1
      end

      results
    end
  end
end
