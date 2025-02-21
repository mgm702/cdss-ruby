# frozen_string_literal: true

module Cdss
  module Parsers
    module StructuresParser
      extend BaseParser

      class << self
        def parse_structures(response)
          parse_collection(response) { |data| build_structure(data) }
        end

        def parse_diversion_records(response, type:)
          parse_collection(response) { |data| build_diversion_record(data, type) }
        end

        def parse_water_classes(response)
          parse_collection(response) { |data| build_water_class(data) }
        end

        private

        def build_structure(data)
          Models::Structure.new(
            wdid: data["wdid"],
            structure_name: data["structureName"],
            structure_type: data["structureType"],
            water_source: data["waterSource"],
            division: safe_integer(data["division"]),
            water_district: safe_integer(data["waterDistrict"]),
            county: data["county"],
            designated_basin: data["designatedBasin"],
            management_district: data["managementDistrict"],
            latitude: safe_float(data["latitude"]),
            longitude: safe_float(data["longitude"]),
            utm_x: safe_float(data["utmX"]),
            utm_y: safe_float(data["utmY"]),
            stream_num: data["streamNum"],
            structure_num: data["structureNum"],
            ciu_code: data["ciuCode"],
            ciucode_desc: data["ciucodeDesc"],
            modified: parse_timestamp(data["modified"]),
            metadata: {}
          )
        end

        def build_diversion_record(data, type)
          Models::DiversionRecord.new(
            wdid: data["wdid"],
            water_class_num: safe_integer(data["waterClassNum"]),
            wc_identifier: data["wcIdentifier"],
            meas_interval: data["measInterval"],
            meas_count: safe_integer(data["measCount"]),
            data_meas_date: parse_data_meas_date(data["dataMeasDate"], type),
            data_value: safe_float(data["dataValue"]),
            meas_units: data["measUnits"],
            obs_code: data["obsCode"],
            approval_status: data["approvalStatus"],
            modified: parse_timestamp(data["modified"]),
            metadata: {}
          )
        end

        def build_water_class(data)
          Models::WaterClass.new(
            wdid: data["wdid"],
            wc_identifier: data["wcIdentifier"],
            por_start: parse_timestamp(data["porStart"]),
            por_end: parse_timestamp(data["porEnd"]),
            div_type: data["divrectype"],
            timestep: data["timestep"],
            units: data["units"],
            source_code: data["sourceCode"],
            use_code: data["useCode"],
            op_code: data["opCode"],
            modified: parse_timestamp(data["modified"]),
            metadata: {}
          )
        end

        def parse_data_meas_date(date_str, type)
          return nil if date_str.nil?

          case type
          when :year
            parse_timestamp("#{date_str}-01-01 00:00:00")
          when :month
            parse_timestamp("#{date_str}-01 00:00:00")
          else
            parse_timestamp(date_str)
          end
        end
      end
    end
  end
end
