require 'ncs_navigator/warehouse'

require 'forwardable'

module NcsNavigator::Warehouse
  class TransformLoad
    extend Forwardable

    attr_reader :configuration
    attr_reader :statuses

    def_delegators :@configuration, :log, :shell

    def initialize(configuration)
      @configuration = configuration
    end

    def run
      position = 0
      @statuses = configuration.transformers.collect do |transformer|
        ::DataMapper.repository(:mdes_warehouse_working) do |repo|
          # redefine identity map as a no-op so it doesn't cache
          # anything. TODO: provide a patch to DataMapper that makes
          # something like this an option.
          def repo.identity_map(model); {}; end

          build_status_for(transformer, position).tap do |status|
            begin
              transformer.transform(status)
            rescue => e
              shell.say_line("\nTransform failed. (See log for more detail.)")
              status.add_error("Transform failed. #{e.class}: #{e}.")
            end
            status.end_time = Time.now
            unless status.save
              shell.say_line("Could not save status for transformer #{status.name}")
              log.warn("Could not save status for transformer #{status.name}")
            end
            position += 1
          end
        end
      end

      if statuses.detect { |s| !s.transform_errors.empty? }
        false
      else
        true
      end
    end

    def build_status_for(transformer, position)
      TransformStatus.new(
        :name => transformer.respond_to?(:name) ? transformer.name : transformer.class.name,
        :start_time => Time.now,
        :position => position
        )
    end
    private :build_status_for
  end
end
