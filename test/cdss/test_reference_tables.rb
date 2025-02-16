require 'test_helper'
require 'pry'

class Cdss::TestReferenceTables < Minitest::Test
  def setup
    @client = Cdss::Client.new
  end

  def test_get_county_reference
    VCR.use_cassette('cdss_get_county_reference') do
      counties = @client.get_reference_table('county')
      assert_kind_of Array, counties
      refute_empty counties

      county = counties.first
      assert_kind_of Cdss::Models::ReferenceTable, county
      assert_base_attributes(county)
      assert_equal 'ADAMS', county.county
    end
  end

  def test_get_waterdistricts_reference
    VCR.use_cassette('cdss_get_waterdistricts_reference') do
      districts = @client.get_reference_table('waterdistricts', division: 1, water_district: 1)
      assert_kind_of Array, districts
      refute_empty districts

      district = districts.first
      assert_kind_of Cdss::Models::ReferenceTable, district
      assert_base_attributes(district)
      assert_equal 1, district.division
      assert_equal 1, district.water_district
    end
  end

  def test_get_waterdivisions_reference
    VCR.use_cassette('cdss_get_waterdivisions_reference') do
      divisions = @client.get_reference_table('waterdivisions', division: 1)
      assert_kind_of Array, divisions
      refute_empty divisions

      division = divisions.first
      assert_kind_of Cdss::Models::ReferenceTable, division
      assert_base_attributes(division)
      assert_equal 1, division.division
    end
  end

  def test_get_designatedbasins_reference
    VCR.use_cassette('cdss_get_designatedbasins_reference') do
      basins = @client.get_reference_table('designatedbasins', designated_basin: 'KIOWA-BIJOU')
      assert_kind_of Array, basins
      refute_empty basins

      basin = basins.first
      assert_kind_of Cdss::Models::ReferenceTable, basin
      assert_base_attributes(basin)
      assert_equal 'KIOWA-BIJOU', basin.designated_basin_name
    end
  end

  def test_get_flags_reference
    VCR.use_cassette('cdss_get_flags_reference') do
      flags = @client.get_reference_table('flags')
      assert_kind_of Array, flags
      refute_empty flags

      flag = flags.first
      assert_kind_of Cdss::Models::ReferenceTable, flag
      assert_base_attributes(flag)
      refute_nil flag.flag
    end
  end

  def test_get_divrectypes_reference
    VCR.use_cassette('cdss_get_divrectypes_reference') do
      types = @client.get_reference_table('divrectypes')
      assert_kind_of Array, types
      refute_empty types

      type = types.first
      assert_kind_of Cdss::Models::ReferenceTable, type
      assert_base_attributes(type)
      refute_nil type.divrectype
    end
  end

  def test_invalid_table_name
    assert_raises(ArgumentError) do
      @client.get_reference_table('invalid_table')
    end
  end

  def test_reference_table_numeric_values
    VCR.use_cassette('cdss_get_reference_numeric') do
      districts = @client.get_reference_table('waterdistricts', division: 1)
      refute_empty districts

      district = districts.first
      assert_kind_of Integer, district.division
      assert_kind_of Integer, district.water_district
    end
  end

  private

  def assert_base_attributes(record)
    %i[name code description].each do |attr|
      assert_respond_to record, attr
    end
  end
end
