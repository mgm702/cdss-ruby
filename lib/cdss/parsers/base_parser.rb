module Cdss
  module Parsers
    module BaseParser
      include Utils
      def parse_collection(response)
        return [] unless response['ResultList']
        if block_given?
          response['ResultList'].map { |data| yield(data) }
        else
          response['ResultList'].map { |data| build_resource(data) }
        end
      end
    end
  end
end
