module Cdss
  module Parsers
    module AdminCallsParser
      extend BaseParser

      class << self
        def parse_admin_calls(response)
          parse_collection(response) { |data| build_call(data) }
        end

        private

        def build_call(data)
          Cdss::Models::AdminCall.new(
            call_number: data['callNumber']&.to_i,
            call_sequence: data['callSequence']&.to_i,
            division: data['division']&.to_i,
            division_name: data['divisionName'],
            district: data['district']&.to_i,
            district_name: data['districtName'],
            water_source: data['waterSource'],
            date_time_set: parse_timestamp(data['dateTimeSet']),
            date_time_released: parse_timestamp(data['dateTimeReleased']),
            set_by_user: data['setByUser'],
            released_by_user: data['releasedByUser'],
            location_wdid: data['locationWdid'],
            location_name: data['locationName'],
            location_stream_mile: data['locationStreamMile']&.to_f,
            source_wdid: data['sourceWdid'],
            source_name: data['sourceName'],
            source_stream_mile: data['sourceStreamMile']&.to_f,
            admin_number: data['adminNumber']&.to_f,
            decreed_amount: data['decreedAmount']&.to_f,
            decreed_unit: data['decreedUnit'],
            comments: data['comments'],
            priority_number: data['priorityNumber']&.to_i,
            appropriation_date: parse_timestamp(data['appropriationDate']),
            adjudication_date: parse_timestamp(data['adjudicationDate']),
            status: data['status'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end
      end
    end
  end
end
