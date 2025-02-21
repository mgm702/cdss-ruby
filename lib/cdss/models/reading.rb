# frozen_string_literal: true

module Cdss
  module Models
    class Reading
      include Cdss::Concerns::WellReadingAttributes
      include Cdss::Concerns::LogReadingAttributes

      BASE_ATTRIBUTES = %i[
        station_num
        station_number
        station_name
        site_id
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
        frost_date_32f_fall
        frost_date_32f_spring
        frost_date_28f_fall
        frost_date_28f_spring
      ].freeze

      ATTRIBUTES = (BASE_ATTRIBUTES + WELL_ATTRIBUTES + LOG_ATTRIBUTES).freeze

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
