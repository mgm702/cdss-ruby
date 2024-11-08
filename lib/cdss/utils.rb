module Cdss
  module Utils
    def batch_dates(start_date, end_date)
      start_date ||= Date.new(1900, 1, 1)
      end_date ||= Date.today

      start_year = start_date.year
      end_year = end_date.year

      if start_year != end_year
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
      else
        [[start_date, end_date]]
      end
    end

    def format_query_param(value)
      return nil if value.nil?
      return value.join('%2C+') if value.is_a?(Array)
      value = value.to_s
      value.include?(' ') ? value.split(' ').join('+') : value
    end

    def build_query(params = {})
      base_query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      params.each do |key, value|
        formatted_value = format_query_param(value)
        base_query[key] = formatted_value if formatted_value
      end

      base_query
    end

    def format_date(date, format = '%m-%d-%Y')
      return nil unless date
      date.strftime(format).gsub('-', '%2F')
    end

    def parse_timestamp(datetime_str)
      DateTime.parse(datetime_str) if datetime_str
    rescue ArgumentError
      nil
    end

    def safe_float(value)
      Float(value)
    rescue TypeError, ArgumentError
      nil
    end

    def safe_integer(value)
      Integer(value)
    rescue TypeError, ArgumentError
      nil
    end

    def fetch_paginated_data(endpoint:, query:)
     page_size = 50000
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
