module Cdss
  module Concerns
    module WellReadingAttributes
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

      def self.included(base)
        base.class_eval do
          attr_accessor(*WELL_ATTRIBUTES)
        end
      end

      def well_reading?
        !well_id.nil?
      end
    end
  end
end
