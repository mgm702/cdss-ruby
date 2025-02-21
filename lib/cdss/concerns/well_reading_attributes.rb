# frozen_string_literal: true

module Cdss
  module Concerns
    # A concern module that adds well reading-related attributes to classes.
    #
    # This module provides a comprehensive set of standardized attributes for well reading data,
    # including identification, location, measurement, and publication information.
    # When included in a class, it dynamically adds accessor methods for these attributes.
    #
    # @example Adding well reading attributes to a class
    #   class WellReading
    #     include Cdss::Concerns::WellReadingAttributes
    #   end
    module WellReadingAttributes
      # Predefined list of well reading attributes
      #
      # @return [Array<Symbol>] List of attributes related to well readings
      WELL_ATTRIBUTES = %i[
        well_id
        well_name
        division
        water_district
        county
        management_district
        designated_basin
        publication
        depth_to_water
        measuring_point_above_land_surface
        measurement_date
        depth_water_below_land_surface
        elevation_of_water
        delta
        published
      ].freeze

      # Dynamically adds accessor methods when the module is included in a class
      #
      # @param [Class] base The class including this module
      def self.included(base)
        base.class_eval do
          attr_accessor(*WELL_ATTRIBUTES)
        end
      end

      # Checks if the instance has a valid well reading
      #
      # @return [Boolean] true if a well ID is present, false otherwise
      # @example Check if a well reading is valid
      #   well_reading.well_reading? # => true or false
      def well_reading?
        !well_id.nil?
      end
    end
  end
end
