module Cdss
  module Models
    class ReferenceTable
      ATTRIBUTES = %i[
        name
        code
        description
        division
        water_district
        water_district_name
        division_name
        county
        management_district
        management_district_name
        designated_basin
        designated_basin_name
        parameter
        flag
        flag_column
        divrectype
        div_rec_type_long
        additional_info
        data_source
        publication_name
        action_name
        action_descr
        ciu_code
        ciu_code_long
        obs_code
        obs_code_long
        obs_descr
        start_iyr
        end_iyr
        not_used_code
        not_used_code_descr
        submission_type
        metadata
      ]

      attr_accessor(*ATTRIBUTES)

      def initialize(**attrs)
        attrs[:metadata] ||= {}
        ATTRIBUTES.each do |attr|
          instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr) && !blank_or_nil?(attrs[attr])
        end
      end

      def blank_or_nil?(value)
        value.nil? || value.to_s.strip.empty?
      end
    end
  end
end
