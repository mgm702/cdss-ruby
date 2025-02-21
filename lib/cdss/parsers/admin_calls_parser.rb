# frozen_string_literal: true

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
            call_number: data["callNumber"]&.to_i,
            call_type: data["callType"],
            date_time_set: parse_timestamp(data["dateTimeSet"]),
            date_time_released: parse_timestamp(data["dateTimeReleased"]),
            water_source_name: data["waterSourceName"],
            location_wdid: data["locationWdid"],
            location_wdid_streammile: data["locationWdidStreammile"]&.to_f,
            location_structure_name: data["locationStructureName"],
            priority_wdid: data["priorityWdid"],
            priority_structure_name: data["priorityStructureName"],
            priority_admin_number: data["priorityAdminNumber"]&.to_f,
            priority_order_number: data["priorityOrderNumber"]&.to_i,
            priority_date: parse_timestamp(data["priorityDate"]),
            priority_number: data["priorityNumber"]&.to_i,
            bounding_wdid: data["boundingWdid"],
            bounding_structure_name: data["boundingStructureName"],
            set_comments: data["setComments"],
            release_comment: data["releaseComment"],
            division: data["division"]&.to_i,
            location_structure_latitude: data["locationStructureLatitude"]&.to_f,
            location_structure_longitude: data["locationStructureLongitude"]&.to_f,
            bounding_structure_latitude: data["boundingStructureLatitude"]&.to_f,
            bounding_structure_longitude: data["boundingStructureLongitude"]&.to_f,
            modified: parse_timestamp(data["modified"]),
            more_information: data["moreInformation"],
            metadata: {}
          )
        end
      end
    end
  end
end
