# frozen_string_literal: true

require "test_helper"

module Cdss
  class TestAdminCalls < Minitest::Test
    def setup
      @client = Cdss::Client.new
    end

    def test_get_active_admin_calls
      VCR.use_cassette("cdss_get_active_admin_calls") do
        calls = @client.get_admin_calls(division: 1)

        assert_kind_of Array, calls
        refute_empty calls

        call = calls.first

        assert_kind_of Cdss::Models::AdminCall, call
        assert_respond_to call, :call_number
        assert_respond_to call, :call_type
        assert_respond_to call, :date_time_set
        assert_respond_to call, :date_time_released
        assert_respond_to call, :water_source_name
        assert_respond_to call, :location_wdid
        assert_respond_to call, :location_wdid_streammile
        assert_respond_to call, :location_structure_name
        assert_respond_to call, :priority_wdid
        assert_respond_to call, :priority_structure_name
        assert_respond_to call, :priority_admin_number
        assert_respond_to call, :priority_order_number
        assert_respond_to call, :priority_date
        assert_respond_to call, :priority_number
        assert_respond_to call, :bounding_wdid
        assert_respond_to call, :bounding_structure_name
        assert_respond_to call, :set_comments
        assert_respond_to call, :release_comment
        assert_respond_to call, :division
        assert_respond_to call, :location_structure_latitude
        assert_respond_to call, :location_structure_longitude
        assert_respond_to call, :bounding_structure_latitude
        assert_respond_to call, :bounding_structure_longitude
        assert_respond_to call, :modified
        assert_respond_to call, :more_information
        assert_respond_to call, :metadata
      end
    end

    def test_get_historical_admin_calls
      VCR.use_cassette("cdss_get_historical_admin_calls") do
        calls = @client.get_admin_calls(
          division: 1,
          start_date: Date.parse("2023-01-01"),
          end_date: Date.parse("2023-12-31"),
          active: false
        )

        assert_kind_of Array, calls
        refute_empty calls
      end
    end

    def test_get_admin_calls_by_location
      VCR.use_cassette("cdss_get_admin_calls_location") do
        calls = @client.get_admin_calls(location_wdid: "0600564")

        assert_kind_of Array, calls
        refute_empty calls
      end
    end

    def test_get_admin_calls_by_call_number
      VCR.use_cassette("cdss_get_admin_calls_call_number") do
        calls = @client.get_admin_calls(call_number: 21_974.00000)

        assert_kind_of Array, calls
        refute_empty calls
      end
    end

    def test_admin_calls_numeric_values
      VCR.use_cassette("cdss_get_admin_calls_numeric") do
        calls = @client.get_admin_calls(division: 1)

        refute_empty calls

        call = calls.first
        assert_kind_of Integer, call.call_number unless call.call_number.nil?
        assert_kind_of Integer, call.division unless call.division.nil?
        assert_kind_of Integer, call.priority_order_number unless call.priority_order_number.nil?
        assert_kind_of Integer, call.priority_number unless call.priority_number.nil?
        assert_kind_of Float, call.location_wdid_streammile unless call.location_wdid_streammile.nil?
        assert_kind_of Float, call.priority_admin_number unless call.priority_admin_number.nil?
        assert_kind_of Float, call.location_structure_latitude unless call.location_structure_latitude.nil?
        assert_kind_of Float, call.location_structure_longitude unless call.location_structure_longitude.nil?
        assert_kind_of Float, call.bounding_structure_latitude unless call.bounding_structure_latitude.nil?
        assert_kind_of Float, call.bounding_structure_longitude unless call.bounding_structure_longitude.nil?
      end
    end

    def test_admin_calls_date_formatting
      VCR.use_cassette("cdss_get_admin_calls_dates") do
        calls = @client.get_admin_calls(
          division: 1,
          start_date: Date.parse("2024-11-01"),
          end_date: Date.parse("2024-11-30")
        )

        refute_empty calls

        call = calls.first
        assert_kind_of DateTime, call.date_time_set unless call.date_time_set.nil?
        assert_kind_of DateTime, call.date_time_released unless call.date_time_released.nil?
        assert_kind_of DateTime, call.priority_date unless call.priority_date.nil?
        assert_kind_of DateTime, call.modified unless call.modified.nil?
      end
    end

    def test_admin_calls_metadata
      VCR.use_cassette("cdss_get_admin_calls_metadata") do
        calls = @client.get_admin_calls(division: 1)

        refute_empty calls

        call = calls.first

        assert_kind_of Hash, call.metadata
      end
    end
  end
end
