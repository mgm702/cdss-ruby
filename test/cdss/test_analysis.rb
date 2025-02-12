require 'test_helper'

class Cdss::TestAnalysisApi < Minitest::Test
  def setup
    @client = Cdss::Client.new
  end

  def test_get_call_analysis_wdid
    VCR.use_cassette('cdss_get_call_analysis_wdid') do
      analyses = @client.get_call_analysis_wdid(
        wdid: '0600564',
        admin_no: '12941.00000',
        start_date: Date.parse('2023-01-01'),
        end_date: Date.parse('2023-12-31')
      )

      assert_kind_of Array, analyses
      refute_empty analyses

      analysis = analyses.first
      assert_kind_of Cdss::Models::CallAnalysis, analysis
      assert_equal '0600564', analysis.wdid
      assert_kind_of DateTime, analysis.analysis_date
      assert_kind_of Float, analysis.percent_time_out_of_priority unless analysis.percent_time_out_of_priority.nil?
    end
  end

  def test_get_call_analysis_wdid_with_batching
    VCR.use_cassette('cdss_get_call_analysis_wdid_batch') do
      analyses = @client.get_call_analysis_wdid(
        wdid: '0600564',
        admin_no: '12941.00000',
        start_date: Date.parse('2022-01-01'),
        end_date: Date.parse('2023-12-31'),
        batch: true
      )

      assert_kind_of Array, analyses
      refute_empty analyses

      # Verify we got data spanning multiple years
      dates = analyses.map(&:analysis_date).compact
      assert dates.any? { |d| d.year == 2022 }
      assert dates.any? { |d| d.year == 2023 }
    end
  end

  def test_get_call_analysis_gnisid
    VCR.use_cassette('cdss_get_call_analysis_gnisid') do
      analyses = @client.get_call_analysis_gnisid(
        gnis_id: '00010001',
        admin_no: '12941.00000',
        stream_mile: 9.76,
        start_date: Date.parse('2023-01-01'),
        end_date: Date.parse('2023-12-31')
      )

      assert_kind_of Array, analyses
      refute_empty analyses

      analysis = analyses.first
      assert_kind_of Cdss::Models::CallAnalysis, analysis
      assert_kind_of DateTime, analysis.analysis_date
      assert_kind_of Float, analysis.admin_number
      assert_kind_of Float, analysis.percent_time_out_of_priority
      assert_kind_of Float, analysis.downstream_call_stream_mile
      assert_kind_of Float, analysis.downstream_call_admin_number

      assert_equal 12941.0, analysis.admin_number
    end
  end

  def test_get_call_analysis_gnisid_with_batching
    VCR.use_cassette('cdss_get_call_analysis_gnisid_batch') do
      analyses = @client.get_call_analysis_gnisid(
        gnis_id: '00010001',
        admin_no: '12941.00000',
        stream_mile: 9.76,
        start_date: Date.parse('2022-01-01'),
        end_date: Date.parse('2023-12-31'),
        batch: true
      )

      assert_kind_of Array, analyses
      refute_empty analyses

      # Verify we got data spanning multiple years
      dates = analyses.map(&:analysis_date).compact
      assert dates.any? { |d| d.year == 2022 }
      assert dates.any? { |d| d.year == 2023 }
    end
  end

  def test_get_source_route_framework
    VCR.use_cassette('cdss_get_source_route_framework') do
      routes = @client.get_source_route_framework(division: 1)
      assert_kind_of Array, routes
      refute_empty routes

      route = routes.first
      assert_kind_of Cdss::Models::SourceRoute, route
      assert_kind_of Integer, route.division
      assert_kind_of Integer, route.water_district
      assert_kind_of String, route.gnis_name
      assert_kind_of Float, route.stream_length unless route.stream_length.nil?
      assert_kind_of Integer, route.tributary_to_level unless route.tributary_to_level.nil?
      assert_kind_of Float, route.tributary_to_stream_mile unless route.tributary_to_stream_mile.nil?
    end
  end

  def test_get_source_route_framework_with_filters
    VCR.use_cassette('cdss_get_source_route_framework_filtered') do
      routes = @client.get_source_route_framework(
        division: 1,
        gnis_name: 'South Boulder Creek',
        water_district: 6
      )

      assert_kind_of Array, routes
      refute_empty routes

      route = routes.first
      assert_equal 1, route.division
      assert_equal 'South Boulder Creek', route.gnis_name
      assert_equal 6, route.water_district
    end
  end

  def test_get_source_route_analysis
    VCR.use_cassette('cdss_get_source_route_analysis') do
      analyses = @client.get_source_route_analysis(
        lt_gnis_id: '00180489',
        lt_stream_mile: 0.0,
        ut_gnis_id: '00010001',
        ut_stream_mile: 10.5
      )

      assert_kind_of Array, analyses
      refute_empty analyses

      analysis = analyses.first
      assert_kind_of Cdss::Models::RouteAnalysis, analysis
      assert_kind_of String, analysis.wdid
      assert_kind_of String, analysis.structure_name
      assert_kind_of Float, analysis.stream_mile unless analysis.stream_mile.nil?
      assert_kind_of Float, analysis.decreed_amount unless analysis.decreed_amount.nil?
    end
  end

  def test_invalid_wdid_call_analysis
    assert_raises(RuntimeError) do
      VCR.use_cassette('cdss_get_call_analysis_invalid_wdid') do
        @client.get_call_analysis_wdid(
          wdid: 'INVALID',
          admin_no: '12941.00000'
        )
      end
    end
  end

  def test_invalid_gnis_call_analysis
    assert_raises(RuntimeError) do
      VCR.use_cassette('cdss_get_call_analysis_invalid_gnis') do
        @client.get_call_analysis_gnisid(
          gnis_id: 'INVALID',
          admin_no: '12941.00000',
          stream_mile: 9.76
        )
      end
    end
  end

  def test_invalid_source_route_analysis
    assert_raises(RuntimeError) do
      VCR.use_cassette('cdss_get_source_route_analysis_invalid') do
        @client.get_source_route_analysis(
          lt_gnis_id: 'INVALID',
          lt_stream_mile: 0.0,
          ut_gnis_id: 'INVALID',
          ut_stream_mile: 10.5
        )
      end
    end
  end
end
