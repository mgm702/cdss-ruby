# frozen_string_literal: true

module Cdss
  module Models
    class Station
      ATTRIBUTES = %i[
        station_num
        abbrev
        usgs_site_id
        name
        agency
        latitude
        longitude
        division
        water_district
        county
        state
        utm_x
        utm_y
        location_accuracy
        start_date
        end_date
        modified
        more_information
        meas_unit
        metadata
      ].freeze

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
