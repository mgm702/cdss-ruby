module Cdss
  module Models
    class Structure
      ATTRIBUTES = %i[
        wdid
        structure_name
        structure_type
        water_source
        location_wdid
        location_name
        location_stream_mile
        gnis_id
        division
        water_district
        county
        designated_basin
        management_district
        latitude
        longitude
        utm_x
        utm_y
        stream_num
        structure_num
        ciu_code
        ciucode_desc
        modified
        stage_volume
        usgs_id
        data_source
        more_information
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

    class DiversionRecord < Structure
      ATTRIBUTES = %i[
        meas_date
        meas_count
        amt_cfs
        amt_af
        data_source
        modified
        div_type
        wc_identifier
        stage
        volume
        start_date
        end_date
        metadata
      ]

      attr_accessor(*ATTRIBUTES)

      def initialize(**attrs)
        super
        attrs[:metadata] ||= {}

        ATTRIBUTES.each do |attr|
          instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr)
        end
      end
    end

    class WaterClass < Structure
      ATTRIBUTES = %i[
        wc_identifier
        por_start
        por_end
        div_type
        timestep
        units
        source_code
        use_code
        op_code
        modified
        metadata
      ]

      attr_accessor(*ATTRIBUTES)

      def initialize(**attrs)
        super
        attrs[:metadata] ||= {}

        ATTRIBUTES.each do |attr|
          instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr)
        end
      end
    end
  end
end
