# frozen_string_literal: true

module Cdss
  module Parsers
    module AnalysisParser
      class << self
        def parse_call_analyses(response, type:)
          parse_collection(response) do |data|
            params = build_call_analysis_params(data, type)
            Cdss::Models::CallAnalysis.new(**params)
          end
        end

        def parse_source_routes(response)
          parse_collection(response) do |data|
            params = build_source_route_params(data)
            Cdss::Models::SourceRoute.new(**params)
          end
        end

        def parse_route_analyses(response)
          parse_collection(response) do |data|
            params = build_route_analysis_params(data)
            Cdss::Models::RouteAnalysis.new(**params)
          end
        end

        private

        def parse_collection(response, &block)
          return [] unless response && response["ResultList"]

          response["ResultList"].map(&block)
        end

        def parse_timestamp(value)
          return nil if value.nil? || value.to_s.empty?

          DateTime.parse(value)
        rescue StandardError
          nil
        end

        def safe_float(value)
          Float(value)
        rescue StandardError
          nil
        end

        def safe_integer(value)
          Integer(value)
        rescue StandardError
          nil
        end

        def build_call_analysis_params(data, _type)
          return {} unless data

          {
            analysis_date: parse_timestamp(data["analysisDate"]),
            wdid: data["analysisWdid"],
            admin_number: safe_float(data["analysisWrAdminNo"]),
            percent_time_out_of_priority: safe_float(data["analysisOutOfPriorityPercentOfDay"]),
            downstream_call_wdid: data["locationWdid"],
            downstream_call_right: data["priorityStructure"],
            downstream_call_stream_mile: safe_float(data["locationWdidStreamMile"]),
            downstream_call_admin_number: safe_float(data["priorityAdminNo"]),
            downstream_call_decreed_amount: nil,
            downstream_call_decreed_unit: nil,
            downstream_call_appropriation_date: parse_timestamp(data["priorityDate"]),
            downstream_call_status: data["callType"],
            modified: parse_timestamp(data["dateTimeSet"]),
            metadata: {
              division: safe_integer(data["division"]),
              date_time_released: parse_timestamp(data["dateTimeReleased"]),
              water_source_name: data["waterSourceName"],
              location_structure: data["locationStructure"],
              priority_order_no: safe_integer(data["priorityOrderNo"]),
              priority_no: data["priorityNo"],
              bounding_wdid: data["boundingWdid"],
              bounding_structure_name: data["boundingStructureName"],
              set_comments: data["setComments"],
              release_comment: data["releaseComment"]
            }
          }.compact
        end

        def build_source_route_params(data)
          return {} unless data

          {
            gnis_id: data["gnisId"],
            gnis_name: data["gnisName"],
            division: safe_integer(data["division"]),
            water_district: safe_integer(data["waterDistrict"]),
            stream_length: safe_float(data["streamLength"]),
            tributary_to_level: safe_integer(data["tributaryToLevel"]),
            tributary_to_gnis_id: data["TributaryToGnisId"],
            tributary_gnis_name: data["tribGnisName"],
            tributary_to_stream_mile: safe_float(data["tributaryToStreamMile"]),
            metadata: {}
          }.compact
        end

        def build_route_analysis_params(data)
          return {} unless data

          {
            wdid: data["wdid"],
            structure_name: data["structureName"],
            stream_mile: safe_float(data["streamMile"]),
            structure_type: data["structureType"],
            decreed_amount: safe_float(data["decreedAmount"]),
            decreed_unit: data["decreedUnit"],
            appropriation_date: parse_timestamp(data["appropriationDate"]),
            admin_number: safe_float(data["adminNo"]),
            modified: parse_timestamp(data["modified"]),
            metadata: {}
          }.compact
        end
      end
    end
  end
end
