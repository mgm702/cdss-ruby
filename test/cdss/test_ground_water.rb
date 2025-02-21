# frozen_string_literal: true

require "test_helper"

module Cdss
  class TestGroundWater < Minitest::Test
    def setup
      @client = Cdss::Client.new
    end

    def test_get_water_level_wells
      VCR.use_cassette("cdss_get_water_level_wells") do
        wells = @client.get_water_level_wells(county: "Denver")

        assert_kind_of Array, wells
        refute_empty wells

        well = wells.first

        assert_kind_of Cdss::Models::Well, well
        assert_respond_to well, :well_id
        assert_respond_to well, :well_name
        assert_respond_to well, :latitude
        assert_respond_to well, :longitude
        assert_respond_to well, :county
        assert_respond_to well, :modified
      end
    end

    def test_get_well_measurements
      VCR.use_cassette("cdss_get_well_measurements") do
        measurements = @client.get_well_measurements(
          wellid: "149733",
          start_date: Date.parse("2021-01-01"),
          end_date: Date.parse("2023-12-31")
        )

        assert_kind_of Array, measurements
        refute_empty measurements

        reading = measurements.first

        assert_kind_of Cdss::Models::Reading, reading

        assert_respond_to reading, :well_id
        assert_respond_to reading, :well_name
        assert_respond_to reading, :division
        assert_respond_to reading, :water_district
        assert_respond_to reading, :county
        assert_respond_to reading, :management_district
        assert_respond_to reading, :designated_basin
        assert_respond_to reading, :publication
        assert_respond_to reading, :depth_to_water
        assert_respond_to reading, :measuring_point_above_land_surface
        assert_respond_to reading, :depth_water_below_land_surface
        assert_respond_to reading, :elevation_of_water
        assert_respond_to reading, :delta
        assert_respond_to reading, :data_source

        assert_equal 149_733, reading.well_id
        assert_kind_of Float, reading.depth_to_water unless reading.depth_to_water.nil?
        unless reading.measuring_point_above_land_surface.nil?
          assert_kind_of Float,
                         reading.measuring_point_above_land_surface
        end
        assert_kind_of Float, reading.depth_water_below_land_surface unless reading.depth_water_below_land_surface.nil?
        assert_kind_of Float, reading.elevation_of_water unless reading.elevation_of_water.nil?
        assert_kind_of Float, reading.delta unless reading.delta.nil?

        refute_nil reading.data_source
      end
    end

    def test_get_geophysical_log_wells
      VCR.use_cassette("cdss_get_geophysical_log_wells") do
        wells = @client.get_geophysical_log_wells(county: "Denver")

        assert_kind_of Array, wells
        refute_empty wells

        well = wells.first

        assert_kind_of Cdss::Models::Well, well
        assert_respond_to well, :well_id
        assert_respond_to well, :well_name
        assert_respond_to well, :depth
        assert_respond_to well, :elevation
        assert_respond_to well, :modified
      end
    end

    def test_get_geophysical_log_picks
      VCR.use_cassette("cdss_get_geophysical_log_picks") do
        picks = @client.get_geophysical_log_picks(wellid: "5419")

        assert_kind_of Array, picks
        refute_empty picks

        pick = picks.first

        assert_kind_of Cdss::Models::Reading, pick
        assert_respond_to pick, :well_id
        assert_respond_to pick, :modified
        assert_respond_to pick, :data_source
        assert_respond_to pick, :aquifer
        assert_respond_to pick, :g_log_top_depth
        assert_respond_to pick, :g_log_base_depth
        assert_respond_to pick, :g_log_top_elev
        assert_respond_to pick, :g_log_base_elev
        assert_respond_to pick, :g_log_thickness
        assert_respond_to pick, :comment
      end
    end

    def test_invalid_wellid_handling
      VCR.use_cassette("cdss_get_water_level_wells_invalid_id") do
        assert_raises(RuntimeError, "API request failed with status 400: Bad Request") do
          @client.get_water_level_wells(wellid: "NONEXISTENT")
        end
      end
    end

    def test_get_well_measurements_date_formatting
      VCR.use_cassette("cdss_get_well_measurements_dates") do
        measurements = @client.get_well_measurements(
          wellid: "149733",
          start_date: Date.parse("2021-01-01"),
          end_date: Date.parse("2023-12-31")
        )

        refute_empty measurements

        reading = measurements.first

        assert_kind_of DateTime, reading.measurement_date
        assert_kind_of DateTime, reading.modified
      end
    end

    def test_well_numeric_values
      VCR.use_cassette("cdss_get_geophysical_log_wells_numeric") do
        wells = @client.get_geophysical_log_wells(wellid: "5419")

        refute_empty wells

        well = wells.first
        assert_kind_of Float, well.depth unless well.depth.nil?
        assert_kind_of Float, well.elevation unless well.elevation.nil?
        assert_kind_of Float, well.latitude unless well.latitude.nil?
        assert_kind_of Float, well.longitude unless well.longitude.nil?
      end
    end

    def test_reading_numeric_values
      VCR.use_cassette("cdss_get_well_measurements_numeric") do
        readings = @client.get_well_measurements(wellid: "149733")

        refute_empty readings

        reading = readings.first
        assert_kind_of Float, reading.value unless reading.value.nil?
      end
    end

    def test_get_geophysical_log_picks_raises_error
      assert_raises(ArgumentError) do
        @client.get_geophysical_log_picks(wellid: nil)
      end
    end
  end
end
