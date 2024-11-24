require 'test_helper'

class Cdss::TestClimate < Minitest::Test
  def setup
    @client = Cdss::Client.new
  end

  def test_get_climate_stations
    VCR.use_cassette('cdss_get_climate_stations') do
      stations = @client.get_climate_stations(county: 'Denver')
      assert_kind_of Array, stations
      refute_empty stations

      station = stations.first
      assert_kind_of Cdss::Models::ClimateStation, station
      assert_respond_to station, :station_number
      assert_respond_to station, :station_name
      assert_respond_to station, :latitude
      assert_respond_to station, :longitude
      assert_respond_to station, :county
      assert_respond_to station, :modified
    end
  end

  def test_get_climate_stations_with_coordinates
    VCR.use_cassette('cdss_get_climate_stations_coordinates') do
      stations = @client.get_climate_stations(
        aoi: { latitude: 39.7392, longitude: -104.9903 },
        radius: 10
      )
      assert_kind_of Array, stations
      refute_empty stations
    end
  end

  def test_get_climate_stations_invalid_aoi
    assert_raises(ArgumentError) do
      @client.get_climate_stations(aoi: "invalid")
    end
  end

  def test_get_climate_frost_dates
    VCR.use_cassette('cdss_get_climate_frost_dates') do
      readings = @client.get_climate_frost_dates(
        station_number: '2184',
        start_date: Date.parse('2021-01-01'),
        end_date: Date.parse('2023-12-31')
      )

      assert_kind_of Array, readings
      refute_empty readings

      reading = readings.first
      assert_kind_of Cdss::Models::Reading, reading
      assert_respond_to reading, :station_number
      assert_respond_to reading, :station_name
      assert_respond_to reading, :measurement_date
      assert_respond_to reading, :frost_date_32f_fall
      assert_respond_to reading, :frost_date_32f_spring
      assert_respond_to reading, :frost_date_28f_fall
      assert_respond_to reading, :frost_date_28f_spring
      assert_respond_to reading, :modified
    end
  end

  # TODO: fix this test
  def test_get_climate_ts_daily
    VCR.use_cassette('cdss_get_climate_ts_daily') do
      readings = @client.get_climate_ts(
        station_number: '2184',
        param: 'MaxTemp',
        start_date: Date.parse('2023-01-01'),
        end_date: Date.parse('2023-12-31'),
        timescale: 'day'
      )

      assert_kind_of Array, readings
      refute_empty readings

      reading = readings.first
      assert_kind_of Cdss::Models::Reading, reading
      assert_respond_to reading, :station_number
      assert_respond_to reading, :station_name
      assert_respond_to reading, :measurement_date
      assert_respond_to reading, :value
      assert_respond_to reading, :flag
      assert_respond_to reading, :modified
    end
  end

  def test_get_climate_ts_monthly
    VCR.use_cassette('cdss_get_climate_ts_monthly') do
      readings = @client.get_climate_ts(
        station_number: 'US1COJF0424',
        param: 'Precip',
        start_date: Date.parse('2023-01-01'),
        end_date: Date.parse('2023-12-31'),
        timescale: 'month'
      )

      assert_kind_of Array, readings
      refute_empty readings

      reading = readings.first
      assert_kind_of Cdss::Models::Reading, reading
      assert_respond_to reading, :station_number
      assert_respond_to reading, :station_name
      assert_respond_to reading, :measurement_date
      assert_respond_to reading, :value
      assert_respond_to reading, :flag
      assert_respond_to reading, :modified
    end
  end

  def test_get_climate_ts_invalid_parameter
    assert_raises(ArgumentError) do
      @client.get_climate_ts(
        station_number: 'US1COJF0424',
        param: 'InvalidParam',
        timescale: 'day'
      )
    end
  end

  def test_get_climate_ts_invalid_timescale
    assert_raises(ArgumentError) do
      @client.get_climate_ts(
        station_number: 'US1COJF0424',
        param: 'MaxTemp',
        timescale: 'invalid'
      )
    end
  end

  # TODO: fix this test
  def test_climate_numeric_values
    VCR.use_cassette('cdss_get_climate_stations_numeric') do
      stations = @client.get_climate_stations(station_name: 'DENVER')
      refute_empty stations

      station = stations.first
      assert_kind_of Float, station.latitude unless station.latitude.nil?
      assert_kind_of Float, station.longitude unless station.longitude.nil?
    end
  end

  def test_climate_reading_numeric_values
    VCR.use_cassette('cdss_get_climate_ts_numeric') do
      readings = @client.get_climate_ts(
        station_number: '2184',
        param: 'MaxTemp',
        timescale: 'day'
      )
      refute_empty readings

      reading = readings.first
      assert_kind_of Float, reading.value unless reading.value.nil?
    end
  end

  # TODO: fix this test
  def test_get_climate_frost_dates_date_formatting
    VCR.use_cassette('cdss_get_climate_frost_dates_dates') do
      readings = @client.get_climate_frost_dates(
        station_number: 'US1COJF0424',
        start_date: Date.parse('2023-12-12'),
        end_date: Date.parse('2023-12-12')
      )
      refute_empty readings

      reading = readings.first
      assert_kind_of DateTime, reading.measurement_date
      assert_kind_of DateTime, reading.modified
    end
  end
end
