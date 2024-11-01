require_relative 'base_reading'

module Cdss
  module Models
    class DayReading < BaseReading
      ATTRIBUTES = %i[meas_date value meas_unit]

      attr_accessor(*ATTRIBUTES, :flags)

      def initialize(**attrs)
        super
        attrs[:flags] ||= {}
        ATTRIBUTES.each { |attr| instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr) }
        @flags = attrs[:flags]
      end
    end
  end
end
