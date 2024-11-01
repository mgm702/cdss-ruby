require_relative 'base_reading'

module Cdss
  module Models
    class DayReading < BaseReading
      READING_ATTRIBUTES = %i[meas_date value meas_unit]

      attr_accessor(*READING_ATTRIBUTES, :flags)

      def initialize(**attrs)
        super
        attrs[:flags] ||= {}
        READING_ATTRIBUTES.each { |attr| instance_variable_set(:"@#{attr}", attrs[attr]) }
        @flags = attrs[:flags]
      end
    end
  end
end
