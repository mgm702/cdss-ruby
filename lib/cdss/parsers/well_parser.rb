module Cdss
  module Parsers
    module WellParser
      extend BaseParser

      class << self
        def parse_wells(response)
          parse_collection(response)
        end

        def parse_well_measurements(response)
          parse_collection(response) { |data| build_measurement(data) }
        end

        def parse_geophysical_wells(response)
          parse_collection(response) { |data| build_geophysical_well(data) }
        end

        def parse_log_picks(response)
          parse_collection(response) { |data| build_log_pick(data) }
        end

        private

        def build_resource(data)
          Cdss::Models::Well.new(
            well_id: data['wellId'],
            well_name: data['wellName'],
            latitude: data['latitude'],
            longitude: data['longitude'],
            location_accuracy: data['locationAccuracy'],
            county: data['county'],
            designated_basin: data['designatedBasin'],
            management_district: data['managementDistrict'],
            division: data['division'],
            water_district: data['waterDistrict'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end

        def build_measurement(data)
          Cdss::Models::Reading.new(
            well_id: data['wellId'],
            measurement_date: parse_timestamp(data['measurementDate']),
            value: safe_float(data['waterLevel']),
            units: data['units'],
            data_source: data['dataSource'],
            collection_method: data['collectionMethod'],
            data_reliability: data['dataReliability'],
            measurement_method: data['measurementMethod'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end

        def build_geophysical_well(data)
          Cdss::Models::Well.new(
            well_id: data['wellId'],
            well_name: data['wellName'],
            latitude: data['latitude'],
            longitude: data['longitude'],
            location_accuracy: data['locationAccuracy'],
            county: data['county'],
            designated_basin: data['designatedBasin'],
            management_district: data['managementDistrict'],
            division: data['division'],
            water_district: data['waterDistrict'],
            depth: safe_float(data['totalDepth']),
            elevation: safe_float(data['groundElevation']),
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end

        def build_log_pick(data)
          Cdss::Models::Reading.new(
            well_id: data['wellId'],
            pick_depth: safe_float(data['pickDepth']),
            formation: data['formation'],
            member: data['member'],
            pick_quality: data['pickQuality'],
            comments: data['comments'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end
      end
    end
  end
end
