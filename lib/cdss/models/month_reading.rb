require_relative 'base_reading'
require_relative 'concerns/flow_statistics'

module Cdss
  module Models
    class MonthReading < BaseReading
      include FlowStatistics

      attr_accessor :cal_year, :cal_month_num

      def initialize(**attrs)
        super
        @cal_year = attrs[:cal_year]
        @cal_month_num = attrs[:cal_month_num]
        initialize_flow_statistics(attrs)
      end
    end
  end
end
