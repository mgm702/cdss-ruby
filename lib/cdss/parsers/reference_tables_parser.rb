# frozen_string_literal: true

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
            name: data["name"],
            code: data["code"],
            description: data["description"],
            division: safe_integer(data["division"]),
            water_district: safe_integer(data["waterDistrict"]),
            water_district_name: data["waterDistrictName"],
            division_name: data["divisionName"],
            county: data["county"],
            management_district: data["managementDistrict"],
            management_district_name: data["managementDistrictName"],
            designated_basin: data["designatedBasin"],
            designated_basin_name: data["designatedBasinName"],
            parameter: data["parameter"] || data["measType"],
            flag: data["flag"],
            flag_column: data["flagColumn"],
            divrectype: data["divRecType"],
            div_rec_type_long: data["divRecTypeLong"],
            additional_info: data["additionalInfo"],
            data_source: data["dataSource"],
            publication_name: data["publicationName"],
            action_name: data["actionName"],
            action_descr: data["actionDescr"],
            ciu_code: data["ciuCode"],
            ciu_code_long: data["ciuCodeLong"],
            obs_code: data["obsCode"],
            obs_code_long: data["obsCodeLong"],
            obs_descr: data["obsDescr"],
            start_iyr: safe_integer(data["startIyr"]),
            end_iyr: safe_integer(data["endIyr"]),
            not_used_code: data["notUsedCode"],
            not_used_code_descr: data["notUsedCodeDescr"],
            submission_type: data["submissionType"],
            metadata: {}
          )
        end
      end
    end
  end
end
