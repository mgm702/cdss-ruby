# frozen_string_literal: true

module Cdss
  # Provides utility methods for handling dates, query parameters, and API pagination.
  #
  # This module contains helper methods used across the CDSS API client for
  # data formatting, safe type conversion, and managing paginated responses.
  module Utils
    # Splits a date range into yearly chunks.
    #
    # @param [Date, nil] start_date Beginning of the date range
    # @param [Date, nil] end_date End of the date range
    # @return [Array<Array<Date>>] Array of date pairs representing yearly chunks
    # @example Split a multi-year range
    #   batch_dates(Date.new(2020,1,1), Date.new(2022,6,30))
    #   #=> [[2020-01-01, 2020-12-31], [2021-01-01, 2021-12-31], [2022-01-01, 2022-06-30]]
    def batch_dates(start_date, end_date)
      start_date ||= Date.new(1900, 1, 1)
      end_date ||= Date.today
      start_year = start_date.year
      end_year = end_date.year
      if start_year == end_year
        [[start_date, end_date]]
      else
        dates = []
        # First year
        dates << [start_date, Date.new(start_year, 12, 31)]
        # Middle years
        ((start_year + 1)...end_year).each do |year|
          dates << [Date.new(year, 1, 1), Date.new(year, 12, 31)]
        end
        # Last year
        dates << [Date.new(end_year, 1, 1), end_date]
        dates
      end
    end

    # Formats a query parameter value for API requests.
    #
    # @param [Object] value The value to format
    # @return [String, nil] Formatted value or nil if input is nil
    # @example Format an array parameter
    #   format_query_param(['a', 'b']) #=> "a,b"
    def format_query_param(value)
      return nil if value.nil?
      return value.join(",") if value.is_a?(Array)

      value.to_s
    end

    # Builds a query hash for API requests.
    #
    # @param [Hash] params Query parameters to include
    # @param [Boolean] encode Whether to URL encode parameter values
    # @return [Hash] Query hash with formatted parameters
    # @example Build a simple query
    #   build_query({ name: "test", id: 123 })
    #   #=> { format: "json", name: "test", id: "123" }
    def build_query(params = {}, encode: false)
      base_query = {
        format: "json"
      }
      params.each do |key, value|
        formatted_value = format_query_param(value)
        if formatted_value
          base_query[key] = encode ? URI.encode_www_form_component(formatted_value) : formatted_value
        end
      end
      base_query
    end

    # Formats a date for API requests.
    #
    # @param [Date] date The date to format
    # @param [Boolean] special_format Whether to use forward slashes instead of hyphens
    # @return [String, nil] Formatted date string or nil if input is nil
    # @example Format a date
    #   format_date(Date.new(2023,1,1)) #=> "01-01-2023"
    def format_date(date, special_format: false)
      return nil unless date

      date = date.strftime("%m-%d-%Y")
      special_format ? date.gsub("-", "%2F") : date
    end

    # Safely parses a timestamp string.
    #
    # @param [String] datetime_str Timestamp string to parse
    # @return [DateTime, nil] Parsed DateTime object or nil if parsing fails
    # @example Parse a timestamp
    #   parse_timestamp("2023-01-01 12:00:00")
    def parse_timestamp(datetime_str)
      DateTime.parse(datetime_str) if datetime_str
    rescue ArgumentError
      nil
    end

    # Safely converts a value to a float.
    #
    # @param [Object] value Value to convert
    # @return [Float, nil] Converted float or nil if conversion fails
    # @example Convert a string to float
    #   safe_float("123.45") #=> 123.45
    def safe_float(value)
      Float(value)
    rescue TypeError, ArgumentError
      nil
    end

    # Safely converts a value to an integer.
    #
    # @param [Object] value Value to convert
    # @return [Integer, nil] Converted integer or nil if conversion fails
    # @example Convert a string to integer
    #   safe_integer("123") #=> 123
    def safe_integer(value)
      Integer(value)
    rescue TypeError, ArgumentError
      nil
    end

    # Fetches all pages of data from a paginated API endpoint.
    #
    # @param [String] endpoint API endpoint path
    # @param [Hash] query Query parameters for the request
    # @yield [Hash] Block to process each page of response data
    # @yieldreturn [Array] Processed records from the response
    # @return [Array] Combined results from all pages
    # @example Fetch paginated data
    #   fetch_paginated_data(endpoint: "/api/data", query: { type: "test" }) do |data|
    #     process_data(data)
    #   end
    def fetch_paginated_data(endpoint:, query:)
      page_size = 50_000
      page_index = 1
      results = []
      loop do
        query = query.merge(pageSize: page_size, pageIndex: page_index)
        response = get(endpoint, query: query)
        data = handle_response(response)
        records = yield(data)
        break if records.empty?

        results.concat(records)
        break if records.size < page_size

        page_index += 1
      end
      results
    end
  end
end
