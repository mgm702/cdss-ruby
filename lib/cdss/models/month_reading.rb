require_relative 'base_reading'
require_relative 'concerns/flow_statistics'

module Cdss
  module Models
    class MonthReading < BaseReading
      include FlowStatistics
      ATTRIBUTES = %i[cal_year cal_month_num]

      attr_accessor(*ATTRIBUTES, :flags)

      def initialize(**attrs)
        super
        attrs[:flags] ||= {}
        ATTRIBUTES.each { |attr| instance_variable_set(:"@#{attr}", attrs[attr]) if attrs.key?(attr) }
        initialize_flow_statistics(attrs)
        @flags = attrs[:flags]
      end
    end
  end
end
