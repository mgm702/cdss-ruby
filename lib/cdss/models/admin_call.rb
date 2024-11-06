module Cdss
  module Models
    class AdminCall
      ATTRIBUTES = %i[
        call_number
        call_sequence
        division
        division_name
        district
        district_name
        water_source
        date_time_set
        date_time_released
        set_by_user
        released_by_user
        location_wdid
        location_name
        location_stream_mile
        source_wdid
        source_name
        source_stream_mile
        admin_number
        decreed_amount
        decreed_unit
        comments
        priority_number
        appropriation_date
        adjudication_date
        status
        modified
        metadata
      ]

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
