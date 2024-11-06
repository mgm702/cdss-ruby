require_relative 'utils'

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

        date_ranges.each_with_index do |range, index|
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

        date_ranges.each_with_index do |range, index|
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
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds'
      }

      query[:division] = division if division
      query[:gnisName] = gnis_name if gnis_name
      query[:waterDistrict] = water_district if water_district

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/analysisservices/watersourcerouteframework/", {
          query: query
        })

        data = handle_response(response)
        routes = Parser.parse_source_routes(data)

        break if routes.empty?

        results.concat(routes)

        break if routes.size < page_size

        page_index += 1
      end

      results
    end

    # Analyzes water source routes between two points.
    #
    # @param [String] lt_gnis_id Lower terminus GNIS ID.
    # @param [Float] lt_stream_mile Lower terminus stream mile.
    # @param [String] ut_gnis_id Upper terminus GNIS ID.
    # @param [Float] ut_stream_mile Upper terminus stream mile.
    # @return [Array<RouteAnalysis>] Array of route analysis records.
    def get_source_route_analysis(lt_gnis_id:, lt_stream_mile:, ut_gnis_id:, ut_stream_mile:)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        ltGnisId: lt_gnis_id,
        ltStreamMile: lt_stream_mile,
        utGnisId: ut_gnis_id,
        utStreamMile: ut_stream_mile
      }

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/analysisservices/watersourcerouteanalysis/", {
          query: query
        })

        data = handle_response(response)
        analyses = Parser.parse_route_analyses(data)

        break if analyses.empty?

        results.concat(analyses)

        break if analyses.size < page_size

        page_index += 1
      end

      results
    end

    private

    def fetch_call_analysis_wdid(wdid:, admin_no:, start_date:, end_date:)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        wdid: wdid,
        adminNo: admin_no
      }

      query[:'startDate'] = start_date.strftime('%m-%d-%Y') if start_date
      query[:'endDate'] = end_date.strftime('%m-%d-%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/analysisservices/callanalysisbywdid/", {
          query: query
        })

        data = handle_response(response)
        analyses = Parser.parse_call_analyses(data, type: :wdid)

        break if analyses.empty?

        results.concat(analyses)

        break if analyses.size < page_size

        page_index += 1
      end

      results
    end

    def fetch_call_analysis_gnisid(gnis_id:, admin_no:, stream_mile:, start_date:, end_date:)
      query = {
        format: 'json',
        dateFormat: 'spaceSepToSeconds',
        gnisId: gnis_id,
        adminNo: admin_no,
        streamMile: stream_mile
      }

      query[:'startDate'] = start_date.strftime('%m-%d-%Y') if start_date
      query[:'endDate'] = end_date.strftime('%m-%d-%Y') if end_date

      page_size = 50000
      page_index = 1
      results = []

      loop do
        query[:pageSize] = page_size
        query[:pageIndex] = page_index

        response = self.class.get("/analysisservices/callanalysisbygnisid/", {
          query: query
        })

        data = handle_response(response)
        analyses = Parser.parse_call_analyses(data, type: :gnis)

        break if analyses.empty?

        results.concat(analyses)

        break if analyses.size < page_size

        page_index += 1
      end

      results
    end
  end
end
