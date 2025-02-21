# frozen_string_literal: true

module Cdss
  module Models
    class WaterRight
      ATTRIBUTES = %i[
        wdid
        water_right_name
        admin_number
        appropriation_date
        padj_date
        adj_type
        adj_date
        order_number
        prior_cases
        status
        trans_id
        trans_type
        case_number
        decreed_uses
        decreed_amount
        decreed_units
        action_comment
        action_update
        county
        water_district
        division
        stream_mile
        structure_type
        latitude
        longitude
        modified
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
