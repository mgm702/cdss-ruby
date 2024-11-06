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
            wdid: data['wdid'],
            structure_name: data['structureName'],
            structure_type: data['structureType'],
            water_source: data['waterSource'],
            division: safe_integer(data['division']),
            water_district: safe_integer(data['waterDistrict']),
            county: data['county'],
            designated_basin: data['designatedBasin'],
            management_district: data['managementDistrict'],
            latitude: safe_float(data['latitude']),
            longitude: safe_float(data['longitude']),
            utm_x: safe_float(data['utmX']),
            utm_y: safe_float(data['utmY']),
            stream_num: data['streamNum'],
            structure_num: data['structureNum'],
            ciu_code: data['ciuCode'],
            ciucode_desc: data['ciucodeDesc'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end

        def build_diversion_record(data, type)
          params = {
            wdid: data['wdid'],
            div_type: data['divrectype'],
            wc_identifier: data['wcIdentifier'],
            data_source: data['dataSource'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          }

          case type
          when :day
            params.merge!(
              meas_date: parse_timestamp(data['dataMeasDate']),
              amt_cfs: safe_float(data['amtCfs']),
              amt_af: safe_float(data['amtAf'])
            )
          when :month, :year
            params.merge!(
              start_date: parse_timestamp(data['startDate']),
              end_date: parse_timestamp(data['endDate']),
              amt_af: safe_float(data['amtAf']),
              meas_count: safe_integer(data['measCount'])
            )
          when :stage_volume
            params.merge!(
              meas_date: parse_timestamp(data['dataMeasDate']),
              stage: safe_float(data['stage']),
              volume: safe_float(data['volume'])
            )
          end

          Models::DiversionRecord.new(**params)
        end

        def build_water_class(data)
          Models::WaterClass.new(
            wdid: data['wdid'],
            wc_identifier: data['wcIdentifier'],
            por_start: parse_timestamp(data['porStart']),
            por_end: parse_timestamp(data['porEnd']),
            div_type: data['divrectype'],
            timestep: data['timestep'],
            units: data['units'],
            source_code: data['sourceCode'],
            use_code: data['useCode'],
            op_code: data['opCode'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end
      end
    end
  end
end
