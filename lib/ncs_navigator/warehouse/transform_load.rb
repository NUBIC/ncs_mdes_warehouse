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
              TransformStatus.transaction do
                if repo.adapter.to_s =~ /Postgres/
                  repo.adapter.execute("SET LOCAL synchronous_commit TO OFF")
                end
                begin
                  transformer.transform(status)
                rescue => e
                  shell.say_line("\nTransform failed. (See log for more detail.)")
                  status.add_error("Transform failed. #{e.class}: #{e}.")
                end
              end
            rescue DataObjects::IntegrityError => e
              shell.say_line("\nTransform failed with data integrity error. (See log for more detail.)")
              log.error("Transform failed with data integrity error: #{e}.")
              status.add_error("Transform failed with data integrity error: #{e}.")
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
        dispatch_post_etl_hooks(:etl_failed)
        false
      else
        dispatch_post_etl_hooks(:etl_succeeded)
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

    def dispatch_post_etl_hooks(method)
      configuration.post_etl_hooks.each do |hook|
        begin
          hook.send(method, statuses) if hook.respond_to?(method)
        rescue => e
          log.error("Error invoking #{method.inspect} on #{hook.inspect}: #{e.class} #{e}.")
        end
      end
    end
    private :dispatch_post_etl_hooks
  end
end
