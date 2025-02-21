# frozen_string_literal: true

module Cdss
  module Models
    class AdminCall
      ATTRIBUTES = %i[
        call_number
        call_type
        date_time_set
        date_time_released
        water_source_name
        location_wdid
        location_wdid_streammile
        location_structure_name
        priority_wdid
        priority_structure_name
        priority_admin_number
        priority_order_number
        priority_date
        priority_number
        bounding_wdid
        bounding_structure_name
        set_comments
        release_comment
        division
        location_structure_latitude
        location_structure_longitude
        bounding_structure_latitude
        bounding_structure_longitude
        modified
        more_information
        metadata
      ].freeze

      attr_accessor(*ATTRIBUTES)

      def initialize(**attrs)
        attrs[:metadata] ||= {}
        ATTRIBUTES.each do |attr|
          instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr)
        end
      end
    end
  end
end
