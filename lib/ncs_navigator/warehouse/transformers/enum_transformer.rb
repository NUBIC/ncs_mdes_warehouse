require 'ncs_navigator/warehouse'

require 'forwardable'

module NcsNavigator::Warehouse::Transformers
  ##
  # A transformer that accepts a series of model instances and
  # {TransformError}s in the form of a ruby Enumerable. An enumerable
  # might be as simple as an array, or it might be a custom class that
  # streams through thousands of instances without having them all in
  # memory at once.
  #
  # Each value yielded by the enumerable may be either an instance of
  # an MDES model or a {TransformError}. If it is a model instance, it
  # will have global values (e.g., PSU ID) applied as necessary,
  # validated, and saved.
  #
  # On the other hand, If it is a `TransformError` the error will be
  # associated with the status for the transform run. The benefit of
  # the enumeration yielding a `TransformError` instead of throwing an
  # exception is that the enumeration may continue after the error is
  # reported. If the error is unrecoverable, the enum should throw an
  # exception instead of returning a
  # `TransformError`. `EnumTransformer` will handle recording the
  # error appropriately in that case.
  class EnumTransformer
    extend Forwardable
    include NcsNavigator::Warehouse::StringifyTrace

    ##
    # @return [Enumerable] the enumeration that will be transformed.
    attr_reader :enum

    def_delegators :@configuration, :log, :shell, :foreign_key_index

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
      begin
        do_transform(status)
      rescue Exception => e
        err = NcsNavigator::Warehouse::TransformError.for_exception(e, 'Enumeration failed.')
        log.error err.message
        status.transform_errors << err
      end
    end

    private

    def do_transform(status)
      enum.each do |record|
        case record
        when NcsNavigator::Warehouse::TransformError
          receive_transform_error(record, status)
        else
          save_model_instance(record, status)
          foreign_key_index.record_and_verify(record)
        end
      end
      foreign_key_index.report_errors(status)
    end

    def save_model_instance(record, status)
      apply_global_values_if_necessary(record)
      if !has_valid_psu?(record)
        msg = "Invalid PSU ID #{record.psu_id.inspect}. The list of valid PSU IDs for this Study Center is #{@configuration.navigator.psus.collect(&:id).inspect}."
        log.error "#{record_ident record}: #{msg}"
        status.unsuccessful_record(record, msg)
      elsif record.valid?
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

    def receive_transform_error(error, status)
      error.id = nil
      status.transform_errors << error
    end

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

    ##
    # Has valid PSU is true if:
    #  * The record has no PSU reference, or
    #  * The record's PSU ID is one of those configured for the
    #    study center
    def has_valid_psu?(record)
      if record.respond_to?(:psu_id)
        @configuration.navigator.psus.collect(&:id).include?(record.psu_id)
      else
        true
      end
    end
  end
end
