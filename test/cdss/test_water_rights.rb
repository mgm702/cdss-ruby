require 'test_helper'

class Cdss::TestWaterRights < Minitest::Test
  def setup
    @client = Cdss::Client.new
  end

  def test_get_water_rights_net_amounts
    VCR.use_cassette('cdss_get_water_rights_net_amounts') do
      rights = @client.get_water_rights_net_amounts(county: 'Denver')
      assert_kind_of Array, rights
      refute_empty rights

      right = rights.first
      assert_kind_of Cdss::Models::WaterRight, right
      assert_respond_to right, :wdid
      assert_respond_to right, :county
      assert_respond_to right, :division
      assert_respond_to right, :water_district
      assert_respond_to right, :modified
    end
  end

  def test_get_water_rights_transactions
    VCR.use_cassette('cdss_get_water_rights_transactions') do
      rights = @client.get_water_rights_transactions(county: 'Denver')
      assert_kind_of Array, rights
      refute_empty rights

      right = rights.first
      assert_kind_of Cdss::Models::WaterRight, right
      assert_respond_to right, :wdid
      assert_respond_to right, :county
      assert_respond_to right, :division
      assert_respond_to right, :water_district
      assert_respond_to right, :modified
    end
  end

  def test_water_rights_aoi_search
    VCR.use_cassette('cdss_get_water_rights_aoi_search') do
      aoi = { latitude: 39.7392, longitude: -104.9903 }
      rights = @client.get_water_rights_net_amounts(aoi: aoi, radius: 10)

      assert_kind_of Array, rights
      refute_empty rights

      right = rights.first
      assert_kind_of Cdss::Models::WaterRight, right
      assert_respond_to right, :latitude
      assert_respond_to right, :longitude
    end
  end

  def test_water_rights_invalid_aoi
    assert_raises(ArgumentError) do
      @client.get_water_rights_net_amounts(aoi: { invalid: 'format' })
    end

    assert_raises(ArgumentError) do
      @client.get_water_rights_transactions(aoi: [1])
    end
  end

  def test_water_rights_pagination_handling
    VCR.use_cassette('cdss_get_water_rights_pagination') do
      rights = @client.get_water_rights_net_amounts(
        division: 1,
        water_district: 4
      )
      assert_kind_of Array, rights

      assert_operator rights.length, :>, 0
      assert_operator rights.length, :<=, 50000
    end
  end

  def test_water_rights_numeric_values
    VCR.use_cassette('cdss_get_water_rights_numeric') do
      rights = @client.get_water_rights_net_amounts(wdid: '1103985')
      refute_empty rights

      right = rights.first
      assert_kind_of Integer, right.division unless right.division.nil?
      assert_kind_of Integer, right.water_district unless right.water_district.nil?
      assert_kind_of Float, right.latitude unless right.latitude.nil?
      assert_kind_of Float, right.longitude unless right.longitude.nil?
    end
  end

  def test_water_rights_date_formatting
    VCR.use_cassette('cdss_get_water_rights_dates') do
      rights = @client.get_water_rights_transactions(wdid: '1103985')
      refute_empty rights

      right = rights.first
      assert_kind_of DateTime, right.modified unless right.modified.nil?
    end
  end

  def test_water_rights_array_format_aoi
    VCR.use_cassette('cdss_get_water_rights_array_aoi') do
      rights = @client.get_water_rights_transactions(
        aoi: [-104.9903, 39.7392],
        radius: 10
      )
      assert_kind_of Array, rights
      refute_empty rights
    end
  end
end
