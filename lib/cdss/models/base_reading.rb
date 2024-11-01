module Cdss
  module Models
    class BaseReading
      BASIC_ATTRIBUTES = %i[station_num abbrev usgs_site_id meas_type data_source modified metadata]

      attr_accessor(*BASIC_ATTRIBUTES)

      def initialize(**attrs)
        attrs[:metadata] ||= {}
        BASIC_ATTRIBUTES.each { |attr| instance_variable_set(:"@#{attr}", attrs[attr]) }
      end
    end
  end
end
