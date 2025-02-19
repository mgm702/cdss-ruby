require 'test_helper'

class Cdss::TestStructuresApi < Minitest::Test
  def setup
    @client = Cdss::Client.new
    Cdss::Models::Structure
    Cdss::Models::DiversionRecord
    Cdss::Models::WaterClass
  end

  def test_get_structures
    VCR.use_cassette('cdss_get_structures') do
      structures = @client.get_structures(wdid: '0100578')
      assert_kind_of Array, structures
      refute_empty structures

      structure = structures.first
      assert_kind_of Cdss::Models::Structure, structure

      assert_equal '0100578', structure.wdid
      assert_equal 'GEORGE WOOD DITCH', structure.structure_name
      assert_equal 'DITCH', structure.structure_type
      assert_equal 'KIOWA CREEK', structure.water_source
      assert_equal 1, structure.division
      assert_equal 1, structure.water_district
      assert_equal 'ELBERT', structure.county
      assert_nil structure.latitude
      assert_nil structure.longitude
      assert_equal 543592.3, structure.utm_x
      assert_equal 4350221.0, structure.utm_y
      assert_equal 'A', structure.ciu_code
      assert_nil structure.structure_num
      assert_empty structure.metadata
      assert_equal DateTime.parse('2010-03-04T07:36:20+00:00'), structure.modified
    end
  end

  def test_get_structures_filter_by_division
    VCR.use_cassette('cdss_get_structures_division') do
      structures = @client.get_structures(division: 1)

      assert_kind_of Array, structures
      refute_empty structures

      structure = structures.first
      assert_kind_of Cdss::Models::Structure, structure
      assert_equal 1, structure.division
    end
  end

  def test_get_structures_filter_by_water_district
    VCR.use_cassette('cdss_get_structures_district') do
      structures = @client.get_structures(water_district: 1)

      assert_kind_of Array, structures
      refute_empty structures

      structure = structures.first
      assert_kind_of Cdss::Models::Structure, structure
      assert_equal 1, structure.water_district
    end
  end

  def test_get_structures_filter_by_county
    VCR.use_cassette('cdss_get_structures_county') do
      structures = @client.get_structures(county: 'ELBERT')

      assert_kind_of Array, structures
      refute_empty structures

      structure = structures.first
      assert_kind_of Cdss::Models::Structure, structure
      assert_equal 'ELBERT', structure.county
    end
  end

  def test_get_diversion_records_ts_daily
    VCR.use_cassette('cdss_get_diversion_records_daily') do
      records = @client.get_diversion_records_ts(
        wdid: '0100504',
        timescale: 'day'
      )
      assert_kind_of Array, records
      refute_empty records

      record = records.first
      assert_kind_of Cdss::Models::DiversionRecord, record
      assert_equal '0100504', record.wdid
      assert_equal 10100504, record.water_class_num
      assert_equal '0100504 Total (Diversion)', record.wc_identifier
      assert_equal 'Daily', record.meas_interval
      assert_equal DateTime.parse('1950-05-16 00:00:00'), record.data_meas_date
      assert_equal 22.0, record.data_value
      assert_equal 'CFS', record.meas_units
      assert_equal '*', record.obs_code
      assert_equal 'Approved', record.approval_status
      assert_equal DateTime.parse('2001-08-14 18:04:00'), record.modified
    end
  end

  def test_get_diversion_records_ts_monthly
    VCR.use_cassette('cdss_get_diversion_records_monthly') do
      records = @client.get_diversion_records_ts(
        wdid: '0100504',
        timescale: 'month'
      )
      assert_kind_of Array, records
      refute_empty records

      record = records.first
      assert_kind_of Cdss::Models::DiversionRecord, record
      assert_equal 10100504, record.water_class_num
      assert_equal 'Daily', record.meas_interval
      assert_equal 16, record.meas_count
      assert_equal 698.192, record.data_value
      assert_equal 'ACFT', record.meas_units
      assert_equal '*', record.obs_code
      assert_equal 'Approved', record.approval_status
      assert_equal DateTime.parse('2001-08-14 18:04:00'), record.modified
    end
  end

  def test_get_diversion_records_ts_yearly
    VCR.use_cassette('cdss_get_diversion_records_yearly') do
      records = @client.get_diversion_records_ts(
        wdid: '0100504',
        timescale: 'year'
      )
      assert_kind_of Array, records
      refute_empty records

      record = records.first
      assert_kind_of Cdss::Models::DiversionRecord, record
      assert_equal '0100504', record.wdid
      assert_equal 10100504, record.water_class_num
      assert_equal '0100504 Total (Diversion)', record.wc_identifier
      assert_equal 'Daily', record.meas_interval
      assert_equal 164, record.meas_count
      assert_equal DateTime.parse('1950-01-01 00:00:00'), record.data_meas_date
      assert_equal 5674.7935, record.data_value
      assert_equal 'ACFT', record.meas_units
      assert_equal '*', record.obs_code
      assert_equal 'Approved', record.approval_status
      assert_equal DateTime.parse('2001-08-14 18:04:00'), record.modified
    end
  end

  def test_get_water_classes
    VCR.use_cassette('cdss_get_water_classes') do
      classes = @client.get_water_classes(wdid: '0100578')

      assert_kind_of Array, classes
      refute_empty classes

      water_class = classes.first
      assert_kind_of Cdss::Models::WaterClass, water_class
      assert_equal '0100578', water_class.wdid
      assert_equal DateTime.parse('2017-10-31T00:00:00'), water_class.por_start
      assert_equal DateTime.parse('2023-06-30T00:00:00'), water_class.por_end
    end
  end

  def test_get_water_classes
    VCR.use_cassette('cdss_get_water_classes') do
      classes = @client.get_water_classes(wdid: '0100578')
      assert_kind_of Array, classes
      refute_empty classes

      water_class = classes.first
      assert_kind_of Cdss::Models::WaterClass, water_class
      assert_equal '0100578', water_class.wdid
      assert_equal 'DivTotal', water_class.div_type
      assert_equal '0100578 Total (Diversions)', water_class.wc_identifier
      assert_equal DateTime.parse('2017-10-31T00:00:00+00:00'), water_class.por_start
      assert_equal DateTime.parse('2023-06-30T00:00:00+00:00'), water_class.por_end
      assert_equal DateTime.parse('2018-02-28T13:51:00+00:00'), water_class.modified
      assert_nil water_class.op_code
      assert_empty water_class.metadata
    end
  end

  def test_invalid_timescale
    assert_raises(ArgumentError) do
      @client.get_diversion_records_ts(
        wdid: '0100578',
        timescale: 'invalid'
      )
    end
  end
end
