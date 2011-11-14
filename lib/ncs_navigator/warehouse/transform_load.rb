require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse
  class TransformLoad
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def run
      statuses = configuration.transformers.collect do |transformer|
        build_status_for(transformer).tap do |status|
          begin
            transformer.transform(status)
          rescue => e
            status.add_error("Transform failed. #{e.class}: #{e}.")
          end
          status.end_time = Time.now
          status.save
        end
      end

      if statuses.detect { |s| !s.transform_errors.empty? }
        false
      else
        true
      end
    end

    def build_status_for(transformer)
      TransformStatus.new(
        :name => transformer.respond_to?(:name) ? transformer.name : transformer.class.name,
        :start_time => Time.now
        )
    end
    private :build_status_for
  end
end
