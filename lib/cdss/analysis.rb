# frozen_string_literal: true

module Cdss
  # Provides methods for accessing analysis services from the CDSS API including
  # call analysis and water source route frameworks.
  module Analysis
    include Utils

    # Performs call analysis by WDID, showing daily priority percentages.
    #
    # @param [String] wdid DWR WDID unique structure identifier code.
    # @param [String, Integer] admin_no Water Right Administration Number.
    # @param [Date, nil] start_date Start date for analysis data.
    # @param [Date, nil] end_date End date for analysis data.
    # @param [Boolean] batch Whether to break date range into yearly batches. Defaults to false.
    # @return [Array<CallAnalysis>] Array of call analysis records.
    # @example Analyze calls for a specific WDID
    #   get_call_analysis_wdid(wdid: "0301234", admin_no: "12345.00000")
    def get_call_analysis_wdid(wdid:, admin_no:, start_date: nil, end_date: nil, batch: false)
      admin_no = admin_no.to_s

      if batch
        results = []
        date_ranges = batch_dates(start_date, end_date)

        date_ranges.each_with_index do |range, _index|
          results.concat(
            fetch_call_analysis_wdid(
              wdid: wdid,
              admin_no: admin_no,
              start_date: range[0],
              end_date: range[1]
            )
          )
        end

        results
      else
        fetch_call_analysis_wdid(
          wdid: wdid,
          admin_no: admin_no,
          start_date: start_date,
          end_date: end_date
        )
      end
    end

    # Performs call analysis by GNIS ID, showing daily priority percentages.
    #
    # @param [String] gnis_id GNIS ID to analyze.
    # @param [String, Integer] admin_no Water Right Administration Number.
    # @param [Float] stream_mile Stream mile for the analysis point.
    # @param [Date, nil] start_date Start date for analysis data.
    # @param [Date, nil] end_date End date for analysis data.
    # @param [Boolean] batch Whether to break date range into yearly batches. Defaults to false.
    # @return [Array<CallAnalysis>] Array of call analysis records.
    def get_call_analysis_gnisid(gnis_id:, admin_no:, stream_mile:, start_date: nil, end_date: nil, batch: false)
      admin_no = admin_no.to_s

      if batch
        results = []
        date_ranges = batch_dates(start_date, end_date)

        date_ranges.each_with_index do |range, _index|
          results.concat(
            fetch_call_analysis_gnisid(
              gnis_id: gnis_id,
              admin_no: admin_no,
              stream_mile: stream_mile,
              start_date: range[0],
              end_date: range[1]
            )
          )
        end

        results
      else
        fetch_call_analysis_gnisid(
          gnis_id: gnis_id,
          admin_no: admin_no,
          stream_mile: stream_mile,
          start_date: start_date,
          end_date: end_date
        )
      end
    end

    # Retrieves the DWR source route framework reference data.
    #
    # @param [Integer, nil] division Water division to filter by.
    # @param [String, nil] gnis_name GNIS Name to filter by.
    # @param [Integer, nil] water_district Water district to filter by.
    # @return [Array<SourceRoute>] Array of source route framework records.
    def get_source_route_framework(division: nil, gnis_name: nil, water_district: nil)
      query = build_query(
        {
          dateFormat: "spaceSepToSeconds",
          division: division,
          gnisName: gnis_name,
          waterDistrict: water_district
        }
      )

      fetch_paginated_data(
        endpoint: "/analysisservices/watersourcerouteframework/",
        query: query
      ) { |data| Parser.parse_source_routes(data) }
    end

    # Analyzes water source routes between two points.
    #
    # @param [String] lt_gnis_id Lower terminus GNIS ID.
    # @param [Float] lt_stream_mile Lower terminus stream mile.
    # @param [String] ut_gnis_id Upper terminus GNIS ID.
    # @param [Float] ut_stream_mile Upper terminus stream mile.
    # @return [Array<RouteAnalysis>] Array of route analysis records.
    def get_source_route_analysis(lt_gnis_id:, lt_stream_mile:, ut_gnis_id:, ut_stream_mile:)
      query = build_query(
        {
          ltGnisId: lt_gnis_id,
          ltStreamMile: lt_stream_mile,
          utGnisId: ut_gnis_id,
          utStreamMile: ut_stream_mile
        }
      )

      fetch_paginated_data(
        endpoint: "/analysisservices/watersourcerouteanalysis/",
        query: query
      ) { |data| Parser.parse_route_analyses(data) }
    end

    private

    # Fetches call analysis data for a specific WDID.
    #
    # @param [String] wdid WDID to analyze
    # @param [String] admin_no Water Right Administration Number
    # @param [Date, nil] start_date Start date for analysis data
    # @param [Date, nil] end_date End date for analysis data
    # @return [Array<CallAnalysis>] Array of call analysis records
    def fetch_call_analysis_wdid(wdid:, admin_no:, start_date:, end_date:)
      query = build_query(
        {
          wdid: wdid,
          adminNo: admin_no,
          startDate: format_date(start_date),
          endDate: format_date(end_date)
        }
      )

      fetch_paginated_data(
        endpoint: "/analysisservices/callanalysisbywdid/",
        query: query
      ) { |data| Parser.parse_call_analyses(data, type: :wdid) }
    end

    # Fetches call analysis data for a specific GNIS ID and stream mile.
    #
    # @param [String] gnis_id GNIS ID to analyze
    # @param [String] admin_no Water Right Administration Number
    # @param [Float] stream_mile Stream mile for the analysis point
    # @param [Date, nil] start_date Start date for analysis data
    # @param [Date, nil] end_date End date for analysis data
    # @return [Array<CallAnalysis>] Array of call analysis records
    def fetch_call_analysis_gnisid(gnis_id:, admin_no:, stream_mile:, start_date:, end_date:)
      query = build_query(
        {
          gnisId: gnis_id,
          adminNo: admin_no,
          streamMile: stream_mile,
          startDate: format_date(start_date),
          endDate: format_date(end_date)
        }
      )

      fetch_paginated_data(
        endpoint: "/analysisservices/callanalysisbygnisid/",
        query: query
      ) { |data| Parser.parse_call_analyses(data, type: :gnis) }
    end
  end
end
