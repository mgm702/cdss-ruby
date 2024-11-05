module Cdss
  module Parsers
    module BaseParser
      def parse_collection(response)
        return [] unless response['ResultList']
        response['ResultList'].map { |data| build_resource(data) }
      end

      def parse_timestamp(datetime_str)
        Time.parse(datetime_str) if datetime_str
      rescue ArgumentError
        nil
      end

      private

      def safe_float(value)
        value&.to_f
      end

      def safe_integer(value)
        value&.to_i
      end
    end
  end
end
