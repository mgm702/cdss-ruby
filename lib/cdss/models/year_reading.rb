require_relative 'base_reading'
require_relative 'concerns/flow_statistics'

module Cdss
  module Models
    class YearReading < BaseReading
      include FlowStatistics

      attr_accessor :water_year

      def initialize(**attrs)
        super
        @water_year = attrs[:water_year]
        initialize_flow_statistics(attrs)
      end
    end
  end
end
