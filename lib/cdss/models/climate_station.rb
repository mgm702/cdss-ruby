module Cdss
  module Models
    class ClimateStation
      ATTRIBUTES = %i[
        station_number
        station_name
        site_id
        division
        water_district
        county
        state
        latitude
        longitude
        utm_x
        utm_y
        elevation
        data_source
        start_date
        end_date
        modified
        more_information
        parameter_types
        metadata
      ]

      attr_accessor(*ATTRIBUTES)

      def initialize(**attrs)
        attrs[:metadata] ||= {}
        attrs[:parameter_types] ||= []

        ATTRIBUTES.each do |attr|
          instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr)
        end
      end
    end
  end
end
