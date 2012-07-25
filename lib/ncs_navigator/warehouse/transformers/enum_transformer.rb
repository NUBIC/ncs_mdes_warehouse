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

    ##
    # @return [Filters] the filters in use on this transformer.
    attr_reader :filters

    def_delegators :@configuration, :log, :shell, :foreign_key_index

    ##
    # @param [Configuration] configuration
    # @param [Enumerable] enum
    # @param [Hash<Symbol, Object>] options
    # @option options [Array<#call>,#call] :filters a list of
    #   filters to use for this transformer
    #
    # @see Filters
    def initialize(configuration, enum, options={})
      @configuration = configuration
      @enum = enum
      filter_list = options.delete(:filters)
      @filters = Filters.new(filter_list ? [*filter_list].compact : [])
    end

    ##
    # A human-readable name for this transformer.
    #
    # @return [String]
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
          filters.call([record]).each do |filtered_record|
            save_model_instance(filtered_record, status)
            foreign_key_index.record_and_verify(record)
          end
        end
      end
      foreign_key_index.report_errors(status)
    end

    def save_model_instance(record, status)
      if !has_valid_psu?(record)
        msg = "Invalid PSU ID. The list of valid PSU IDs for this Study Center is #{@configuration.navigator.psus.collect(&:id).inspect}."
        log.error "#{record_ident record}: #{msg}"
        status.unsuccessful_record(record, msg,
          :attribute_name => 'psu_id',
          :attribute_value => record.psu_id.inspect)
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
        log.error "Invalid record. #{record_messages(record).join(' ')}"
        record.errors.keys.each do |prop|
          record.errors[prop].each do |e|
            status.unsuccessful_record(
              record, "Invalid: #{e}.",
              :attribute_name => prop,
              :attribute_value => record.send(prop).inspect
            )
          end
        end
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
