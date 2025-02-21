# frozen_string_literal: true

require "test_helper"

module Cdss
  class TestTelemetry < Minitest::Test
    def setup
      @client = Cdss.client
    end

    def test_get_telemetry_stations
      VCR.use_cassette("cdss_get_telemetry_stations") do
        stations = @client.get_telemetry_stations(county: "Denver")

        assert_kind_of Array, stations
        refute_empty stations
        station = stations.first

        assert_kind_of Cdss::Models::Station, station
      end
    end

    def test_get_telemetry_ts_day
      VCR.use_cassette("cdss_get_telemetry_ts_day") do
        readings = @client.get_telemetry_ts(
          abbrev: "PLACHECO",
          parameter: "DISCHRG",
          start_date: Date.parse("2021-01-01"),
          end_date: Date.parse("2021-12-31"),
          timescale: "day"
        )

        assert_kind_of Array, readings
        refute_empty readings
        reading = readings.first

        assert_kind_of Cdss::Models::Reading, reading
        assert_equal "DISCHRG", reading.parameter
      end
    end

    def test_get_telemetry_ts_hour
      VCR.use_cassette("cdss_get_telemetry_ts_hour") do
        readings = @client.get_telemetry_ts(
          abbrev: "PLACHECO",
          parameter: "DISCHRG",
          start_date: Date.parse("2021-01-01"),
          end_date: Date.parse("2021-12-31"),
          timescale: "hour"
        )

        assert_kind_of Array, readings
        refute_empty readings
        reading = readings.first

        assert_kind_of Cdss::Models::Reading, reading
        assert_equal "DISCHRG", reading.parameter
      end
    end

    def test_get_telemetry_ts_raw
      VCR.use_cassette("cdss_get_telemetry_ts_raw") do
        readings = @client.get_telemetry_ts(
          abbrev: "PLACHECO",
          parameter: "DISCHRG",
          start_date: Date.parse("2021-01-01"),
          end_date: Date.parse("2021-12-31"),
          timescale: "raw"
        )

        assert_kind_of Array, readings
        refute_empty readings
        reading = readings.first

        assert_kind_of Cdss::Models::Reading, reading
        assert_equal "DISCHRG", reading.parameter
      end
    end
  end
end
