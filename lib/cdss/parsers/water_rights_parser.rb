module Cdss
  module Parsers
    module WaterRightsParser
      extend BaseParser

      class << self
        def parse_water_rights(response, type:)
          parse_collection(response) do |data|
            case type
            when :net_amount
              build_net_amount(data)
            when :transaction
              build_transaction(data)
            else
              raise ArgumentError, "Invalid water rights type: #{type}"
            end
          end
        end

        private

        def build_net_amount(data)
          Cdss::Models::WaterRight.new(
            wdid: data['wdid'],
            water_right_name: data['waterRightName'],
            admin_number: data['adminNumber']&.to_f,
            appropriation_date: parse_timestamp(data['appropriationDate']),
            padj_date: parse_timestamp(data['padjDate']),
            adj_type: data['adjType'],
            order_number: data['orderNumber'],
            prior_cases: data['priorCases'],
            adj_date: parse_timestamp(data['adjDate']),
            status: data['status'],
            decreed_uses: data['decreedUses'],
            decreed_amount: data['decreedAmount']&.to_f,
            decreed_units: data['decreedUnits'],
            county: data['county'],
            water_district: data['waterDistrict']&.to_i,
            division: data['division']&.to_i,
            stream_mile: data['streamMile']&.to_f,
            structure_type: data['structureType'],
            latitude: data['latitude']&.to_f,
            longitude: data['longitude']&.to_f,
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end

        def build_transaction(data)
          Cdss::Models::WaterRight.new(
            wdid: data['wdid'],
            water_right_name: data['waterRightName'],
            trans_id: data['transId'],
            trans_type: data['transType'],
            case_number: data['caseNumber'],
            adj_date: parse_timestamp(data['adjDate']),
            admin_number: data['adminNumber']&.to_f,
            order_number: data['orderNumber'],
            prior_cases: data['priorCases'],
            decreed_uses: data['decreedUses'],
            decreed_amount: data['decreedAmount']&.to_f,
            decreed_units: data['decreedUnits'],
            action_comment: data['actionComment'],
            action_update: data['actionUpdate'],
            county: data['county'],
            water_district: data['waterDistrict']&.to_i,
            division: data['division']&.to_i,
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end
      end
    end
  end
end
