# frozen_string_literal: true

module Cdss
  module Concerns
    module LogReadingAttributes
      LOG_ATTRIBUTES = %i[
        aquifer
        g_log_top_depth
        g_log_base_depth
        g_log_top_elev
        g_log_base_elev
        g_log_thickness
        comment
      ].freeze

      def self.included(base)
        base.class_eval do
          attr_accessor(*LOG_ATTRIBUTES)
        end
      end

      def log_reading?
        !aquifer.nil? || !g_log_thickness.nil?
      end
    end
  end
end
