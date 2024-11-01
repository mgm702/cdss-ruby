module Cdss
  module Models
    module FlowStatistics
      FLOW_ATTRIBUTES = %i[min_q_cfs max_q_cfs avg_q_cfs total_q_af meas_count]

      def self.included(base)
        base.attr_accessor(*FLOW_ATTRIBUTES)
      end

      private

      def initialize_flow_statistics(stats)
        FLOW_ATTRIBUTES.each { |attr| instance_variable_set(:"@#{attr}", stats[attr]) if attrs.key?(attr) }
      end
    end
  end
end
