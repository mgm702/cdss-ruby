module Cdss
  module Models
    class ReferenceTable
      ATTRIBUTES = %i[
        name
        code
        description
        division
        water_district
        county
        management_district
        designated_basin
        parameter
        flag
        divrectype
        additional_info
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
