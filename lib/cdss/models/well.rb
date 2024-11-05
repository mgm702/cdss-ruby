module Cdss
  module Models
    class Well
      ATTRIBUTES = %i[
        well_id
        well_name
        latitude
        longitude
        location_accuracy
        county
        designated_basin
        management_district
        division
        water_district
        depth
        elevation
        start_date
        end_date
        modified
        data_source
        more_information
        total_depth
        ground_elevation
        utm_x
        utm_y
        state
        metadata
      ]

      attr_accessor(*ATTRIBUTES)

      def initialize(**attrs)
        attrs[:metadata] ||= {}

        ATTRIBUTES.each do |attr|
          instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr) && attrs[attr]
        end
      end
    end
  end
end
