module Cdss
  module Parsers
    module ReferenceTablesParser
      extend BaseParser

      class << self
        def parse_reference_table(response)
          parse_collection(response) { |data| build_reference(data) }
        end

        private

        def build_reference(data)
          Models::ReferenceTable.new(
            name: data['name'],
            code: data['code'],
            description: data['description'],
            division: safe_integer(data['division']),
            water_district: safe_integer(data['waterDistrict']),
            county: data['county'],
            management_district: data['managementDistrict'],
            designated_basin: data['designatedBasin'],
            parameter: data['parameter'] || data['measType'],
            flag: data['flag'],
            divrectype: data['divRecType'],
            additional_info: data['additionalInfo'],
            metadata: {}
          )
        end
      end
    end
  end
end
