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
      "EnumTransformer for #{enum.class}"
    end

    ##
    # Takes each in-memory record provided by the configured
    # `Enumerable`, validates it, and saves it if it is valid.
    #
    # @param [TransformStatus] status
    # @return [void]
    def transform(status)
      enum.each do |record|
        apply_psu_if_necessary(record)
        if record.valid?
          log.debug("Saving valid record #{record_ident record}.")
          begin
            unless record.save
              msg = "Could not save. #{record_ident(record)}."
              log.error msg
              status.unsuccessful_record(record, msg)
            end
          rescue => e
            msg = "Error on save. #{e.class}: #{e}. #{record_ident(record)}."
            log.error msg
            status.unsuccessful_record(record, msg)
          end
        else
          messages = record.errors.keys.collect { |prop|
            record.errors[prop].collect { |e|
              v = record.send(prop)
              "#{e} (#{prop}=#{v.inspect})."
            }
          }.flatten
          msg = "Invalid record. #{messages.join(' ')} #{record_ident(record)}."
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

    def apply_psu_if_necessary(record)
      if record.respond_to?(:psu_id=) && record.respond_to?(:psu_id)
        unless record.psu_id
          record.psu_id = @configuration.navigator.psus.first.id
        end
      end
    end
  end
end
