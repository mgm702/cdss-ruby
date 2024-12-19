require 'test_helper'

class Cdss::TestAdminCalls < Minitest::Test
  def setup
    @client = Cdss::Client.new
  end

  def test_get_active_admin_calls
    VCR.use_cassette('cdss_get_active_admin_calls') do
      calls = @client.get_admin_calls(division: 1)
      assert_kind_of Array, calls
      refute_empty calls

      call = calls.first
      assert_kind_of Cdss::Models::AdminCall, call
      assert_respond_to call, :call_number
      assert_respond_to call, :call_sequence
      assert_respond_to call, :division
      assert_respond_to call, :division_name
      assert_respond_to call, :district
      assert_respond_to call, :district_name
      assert_respond_to call, :water_source
      assert_respond_to call, :date_time_set
      assert_respond_to call, :date_time_released
      assert_respond_to call, :set_by_user
      assert_respond_to call, :released_by_user
      assert_respond_to call, :location_wdid
      assert_respond_to call, :location_name
      assert_respond_to call, :location_stream_mile
      assert_respond_to call, :source_wdid
      assert_respond_to call, :source_name
      assert_respond_to call, :source_stream_mile
      assert_respond_to call, :admin_number
      assert_respond_to call, :decreed_amount
      assert_respond_to call, :decreed_unit
      assert_respond_to call, :comments
      assert_respond_to call, :priority_number
      assert_respond_to call, :appropriation_date
      assert_respond_to call, :adjudication_date
      assert_respond_to call, :status
      assert_respond_to call, :modified
      assert_respond_to call, :metadata
    end
  end

  def test_get_historical_admin_calls
    VCR.use_cassette('cdss_get_historical_admin_calls') do
      calls = @client.get_admin_calls(
        division: 1,
        start_date: Date.parse('2023-01-01'),
        end_date: Date.parse('2023-12-31'),
        active: false
      )
      assert_kind_of Array, calls
      refute_empty calls
    end
  end

  # TODO: fix this test
  def test_get_admin_calls_by_location
    VCR.use_cassette('cdss_get_admin_calls_location') do
      calls = @client.get_admin_calls(location_wdid: '0100929')
      assert_kind_of Array, calls
      refute_empty calls
    end
  end

  # TODO: fix this test
  def test_get_admin_calls_by_multiple_locations
    VCR.use_cassette('cdss_get_admin_calls_multiple_locations') do
      calls = @client.get_admin_calls(location_wdid: ['0100929', '0100930'])
      assert_kind_of Array, calls
      refute_empty calls
    end
  end

  # TODO: fix this test
  def test_get_admin_calls_by_call_number
    VCR.use_cassette('cdss_get_admin_calls_call_number') do
      calls = @client.get_admin_calls(call_number: 1234)
      assert_kind_of Array, calls
      refute_empty calls
    end
  end

  def test_admin_calls_numeric_values
    VCR.use_cassette('cdss_get_admin_calls_numeric') do
      calls = @client.get_admin_calls(division: 1)
      refute_empty calls

      call = calls.first
      assert_kind_of Integer, call.call_number unless call.call_number.nil?
      assert_kind_of Integer, call.call_sequence unless call.call_sequence.nil?
      assert_kind_of Integer, call.division unless call.division.nil?
      assert_kind_of Integer, call.district unless call.district.nil?
      assert_kind_of Float, call.location_stream_mile unless call.location_stream_mile.nil?
      assert_kind_of Float, call.source_stream_mile unless call.source_stream_mile.nil?
      assert_kind_of Float, call.admin_number unless call.admin_number.nil?
      assert_kind_of Float, call.decreed_amount unless call.decreed_amount.nil?
      assert_kind_of Integer, call.priority_number unless call.priority_number.nil?
    end
  end

  # TODO: fix this test
  def test_admin_calls_date_formatting
    VCR.use_cassette('cdss_get_admin_calls_dates') do
      calls = @client.get_admin_calls(
        division: 1,
        start_date: Date.parse('2023-01-01'),
        end_date: Date.parse('2023-12-31')
      )
      refute_empty calls

      call = calls.first
      assert_kind_of DateTime, call.date_time_set unless call.date_time_set.nil?
      assert_kind_of DateTime, call.date_time_released unless call.date_time_released.nil?
      assert_kind_of DateTime, call.appropriation_date unless call.appropriation_date.nil?
      assert_kind_of DateTime, call.adjudication_date unless call.adjudication_date.nil?
      assert_kind_of DateTime, call.modified unless call.modified.nil?
    end
  end

  def test_admin_calls_metadata
    VCR.use_cassette('cdss_get_admin_calls_metadata') do
      calls = @client.get_admin_calls(division: 1)
      refute_empty calls

      call = calls.first
      assert_kind_of Hash, call.metadata
    end
  end
end
