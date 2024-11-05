module Cdss
  module Models
    class Reading
      ATTRIBUTES = %i[
        station_num
        abbrev
        parameter
        usgs_site_id
        meas_type
        data_source
        modified
        metadata
        flags
        meas_date
        value
        meas_unit
        meas_value
        meas_date_time
        cal_year
        cal_month_num
        water_year
        min_q_cfs
        max_q_cfs
        avg_q_cfs
        total_q_af
        meas_count
      ].freeze

      attr_accessor(*ATTRIBUTES)

      def initialize(**attrs)
        attrs[:metadata] ||= {}
        attrs[:flags] ||= {}

        ATTRIBUTES.each do |attr|
          instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr) && attrs[attr]
        end
      end
    end
  end
end
