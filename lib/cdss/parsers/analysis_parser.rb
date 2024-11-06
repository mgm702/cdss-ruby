module Cdss
  module Parsers
    # Parses analysis-related data from CDSS API responses into appropriate model objects.
    # Handles call analyses, source routes, and route analyses.
    module AnalysisParser
      extend BaseParser

      class << self
        # Parses call analysis data from API response.
        #
        # @param response [Hash] The API response containing call analysis data
        # @param type [Symbol] The type of analysis (:wdid or :gnis)
        # @return [Array<Cdss::Models::CallAnalysis>] Array of call analysis objects
        def parse_call_analyses(response, type:)
          parse_collection(response) { |data| build_analysis(Cdss::Models::CallAnalysis, data, type) }
        end

        # Parses source route data from API response.
        #
        # @param response [Hash] The API response containing source route data
        # @return [Array<Cdss::Models::SourceRoute>] Array of source route objects
        def parse_source_routes(response)
          parse_collection(response) { |data| build_analysis(Cdss::Models::SourceRoute, data) }
        end

        # Parses route analysis data from API response.
        #
        # @param response [Hash] The API response containing route analysis data
        # @return [Array<Cdss::Models::RouteAnalysis>] Array of route analysis objects
        def parse_route_analyses(response)
          parse_collection(response) { |data| build_analysis(Cdss::Models::RouteAnalysis, data) }
        end

        private

        def build_analysis(klass, data, type = nil)
          params = case klass
          when Cdss::Models::CallAnalysis
            build_call_analysis_params(data, type)
          when Cdss::Models::SourceRoute
            build_source_route_params(data)
          when Cdss::Models::RouteAnalysis
            build_route_analysis_params(data)
          end

          klass.new(**params)
        end

        def build_call_analysis_params(data, type)
          params = {
            analysis_date: parse_timestamp(data['analysisDate']),
            admin_number: safe_float(data['adminNo']),
            percent_time_out_of_priority: safe_float(data['percentTimeOutOfPriority']),
            downstream_call_wdid: data['downstreamCallWdid'],
            downstream_call_right: data['downstreamCallRight'],
            downstream_call_stream_mile: safe_float(data['downstreamCallStreamMile']),
            downstream_call_admin_number: safe_float(data['downstreamCallAdminNo']),
            downstream_call_decreed_amount: safe_float(data['downstreamCallDecreedAmount']),
            downstream_call_decreed_unit: data['downstreamCallDecreedUnit'],
            downstream_call_appropriation_date: parse_timestamp(data['downstreamCallAppropriationDate']),
            downstream_call_status: data['downstreamCallStatus'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          }

          case type
          when :wdid
            params[:wdid] = data['wdid']
          when :gnis
            params[:gnis_id] = data['gnisId']
            params[:stream_mile] = safe_float(data['streamMile'])
          end

          params
        end

        def build_source_route_params(data)
          {
            gnis_id: data['gnisId'],
            gnis_name: data['gnisName'],
            stream_name: data['streamName'],
            division: safe_integer(data['division']),
            water_district: safe_integer(data['waterDistrict']),
            county: data['county'],
            start_mile: safe_float(data['startMile']),
            end_mile: safe_float(data['endMile']),
            total_length: safe_float(data['totalLength']),
            modified: parse_timestamp(data['modified']),
            metadata: {}
          }
        end

        def build_route_analysis_params(data)
          {
            wdid: data['wdid'],
            structure_name: data['structureName'],
            stream_mile: safe_float(data['streamMile']),
            structure_type: data['structureType'],
            decreed_amount: safe_float(data['decreedAmount']),
            decreed_unit: data['decreedUnit'],
            appropriation_date: parse_timestamp(data['appropriationDate']),
            admin_number: safe_float(data['adminNo']),
            modified: parse_timestamp(data['modified']),
            metadata: {}
          }
        end
      end
    end
  end
end
