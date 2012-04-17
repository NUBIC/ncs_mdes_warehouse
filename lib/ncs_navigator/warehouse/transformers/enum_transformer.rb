require 'ncs_navigator/warehouse'

require 'forwardable'

module NcsNavigator::Warehouse::Transformers
  ##
  # A transformer that accepts a series of model instances in the form
  # of a ruby Enumerable. An enumerable might be as simple as an
  # array, or it might be a custom class that streams through
  # thousands of instances without having them all in memory at once.
  class EnumTransformer
    extend Forwardable

    ##
    # @return [Enumerable] the enumeration that will be transformed.
    attr_reader :enum

    def_delegators :@configuration, :log, :shell

    ##
    # @param [Configuration] configuration
    # @param [Enumerable] enum
    def initialize(configuration, enum)
      @configuration = configuration
      @enum = enum
    end

    def name
      enum_name = if enum.respond_to?(:name)
                    enum.name
                  else
                    enum.class
                  end
      "EnumTransformer for #{enum_name}"
    end

    ##
    # Takes each in-memory record provided by the configured
    # `Enumerable`, validates it, and saves it if it is valid.
    #
    # @param [TransformStatus] status
    # @return [void]
    def transform(status)
      enum.each do |record|
        apply_global_values_if_necessary(record)
        if record.valid?
          log.debug("Saving valid record #{record_ident record}.")
          begin
            unless record.save
              msg = "Could not save valid record #{record.inspect}. #{record_messages(record).join(' ')}"
              log.error msg
              status.unsuccessful_record(record, msg)
            end
          rescue => e
            msg = "Error on save. #{e.class}: #{e}."
            log.error msg
            status.unsuccessful_record(record, msg)
          end
        else
          msg = "Invalid record. #{record_messages(record).join(' ')}"
          log.error msg
          status.unsuccessful_record(record, msg)
        end
        status.record_count += 1
      end
    end

    private

    def record_ident(rec)
      # No composite keys in the MDES
      '%s %s=%s' % [
        rec.class.name.demodulize, rec.class.key.first.name, rec.key.try(:first).inspect]
    end

    def record_messages(record)
      record.errors.keys.collect { |prop|
        record.errors[prop].collect { |e|
          v = record.send(prop)
          "#{e} (#{prop}=#{v.inspect})."
        }
      }.flatten
    end

    def apply_global_values_if_necessary(record)
      {
        :psu_id => @configuration.navigator.psus.first.id,
        :recruit_type => @configuration.navigator.recruitment_type_id
      }.each do |attr, value|
        setter = :"#{attr}="
        if record.respond_to?(setter) && record.respond_to?(attr)
          unless record.send(attr)
            record.send(setter, value)
          end
        end
      end
    end
  end
end
