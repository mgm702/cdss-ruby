require 'test_helper'

class Cdss::TestSurfaceWater < Minitest::Test
  def setup
    @client = Cdss::Client.new
  end

  def test_get_sw_stations
    VCR.use_cassette('cdss_get_sw_stations') do
      stations = @client.get_sw_stations(county: 'Denver')
      assert_kind_of Array, stations
      refute_empty stations
      station = stations.first
      assert_kind_of Cdss::Models::Station, station
    end
  end

  def test_get_sw_ts_day
    VCR.use_cassette('cdss_get_sw_ts_day') do
      readings = @client.get_sw_ts(
        abbrev: 'PLACHECO',
        start_date: Date.parse('2021-01-01'),
        end_date: Date.parse('2021-12-31'),
        timescale: 'day'
      )
      assert_kind_of Array, readings
      refute_empty readings
      reading = readings.first
      assert_kind_of Cdss::Models::Reading, reading
    end
  end

  def test_get_sw_ts_month
    VCR.use_cassette('cdss_get_sw_ts_month') do
      readings = @client.get_sw_ts(
        abbrev: 'PLACHECO',
        start_date: Date.parse('2021-01-01'),
        end_date: Date.parse('2021-12-31'),
        timescale: 'month'
      )
      assert_kind_of Array, readings
      refute_empty readings
      reading = readings.first
      assert_kind_of Cdss::Models::Reading, reading
    end
  end

  def test_get_sw_ts_year
    VCR.use_cassette('cdss_get_sw_ts_year') do
      readings = @client.get_sw_ts(
        abbrev: 'PLACHECO',
        start_date: Date.parse('2021-01-01'),
        end_date: Date.parse('2021-12-31'),
        timescale: 'day'
      )
      assert_kind_of Array, readings
      refute_empty readings
      reading = readings.first
      assert_kind_of Cdss::Models::Reading, reading
    end
  end
end
