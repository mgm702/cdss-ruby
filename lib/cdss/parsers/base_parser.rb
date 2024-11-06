require_relative '../utils'
module Cdss
  module Parsers
    module BaseParser
      include Utils
      def parse_collection(response)
        return [] unless response['ResultList']
        response['ResultList'].map { |data| build_resource(data) }
      end
    end
  end
end
