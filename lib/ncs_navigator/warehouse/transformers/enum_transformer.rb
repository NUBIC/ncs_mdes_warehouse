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

    ##
    # @return [Symbol] the name of the duplicates mode in use on this
    # transformer.
    attr_reader :duplicates

    def_delegators :@configuration, :log, :shell, :foreign_key_index

    ##
    # @param [Configuration] configuration
    # @param [Enumerable] enum
    # @param [Hash<Symbol, Object>] options
    # @option options [Array<#call>,#call] :filters a list of
    #   filters to use for this transformer
    # @option options [:error,:ignore,:replace] the desired behavior when this
    #   transformer encounters a record with the same PK as one already seen.
    #   `:error` means blindly save (and let the database error out).
    #   `:ignore` means do not attempt to save the duplicate.
    #   `:replace` means substitute the duplicate for the existing record.
    #
    # @see Filters
    def initialize(configuration, enum, options={})
      @configuration = configuration
      @enum = enum
      filter_list = options.delete(:filters)
      @filters = Filters.new(filter_list ? [*filter_list].compact : [])
      @duplicates = options.delete(:duplicates) || :error
      @duplicates_strategy = select_duplicates_strategy
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
      rescue => e
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
            saved_record = save_model_instance(filtered_record, status)
            foreign_key_index.record_and_verify(saved_record) if saved_record
          end
        end
      end
      foreign_key_index.report_errors(status)
    end

    def save_model_instance(incoming_record, status)
      record = process_duplicate_if_appropriate(incoming_record)
      unless record
        log.info("Ignoring duplicate record #{record_ident incoming_record}.")
        status.record_count += 1
        return
      end

      saved_record =
        if !has_valid_psu?(record)
          msg = "Invalid PSU ID. The list of valid PSU IDs for this Study Center is #{@configuration.navigator.psus.collect(&:id).inspect}."
          log.error "#{record_ident record}: #{msg}"
          status.unsuccessful_record(record, msg,
            :attribute_name => 'psu_id',
            :attribute_value => record.psu_id.inspect)
          nil
        elsif record.valid?
          log.debug("Saving valid record #{record_ident record}.")
          begin
            if record.save
              record
            else
              msg = "Could not save valid record #{record.inspect}. #{record_messages(record).join(' ')}"
              log.error msg
              status.unsuccessful_record(record, msg)
              nil
            end
          rescue => e
            msg = "Error on save. #{e.class}: #{e}."
            log.error msg
            status.unsuccessful_record(record, msg)
            nil
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
          nil
        end
      status.record_count += 1
      saved_record
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

    def process_duplicate_if_appropriate(record)
      if @duplicates_strategy.duplicate?(record)
        @duplicates_strategy.to_save(record)
      else
        record
      end
    end

    def select_duplicates_strategy
      case duplicates
      when :error
        ErrorDuplicatesStrategy.new
      when :ignore
        IgnoreDuplicatesStrategy.new(@configuration)
      when :replace
        ReplaceDuplicatesStrategy.new(@configuration)
      else
        fail "Unknown duplicates mode #{duplicates.inspect}."
      end
    end

    ##
    # @private
    class ErrorDuplicatesStrategy
      def duplicate?(record)
        false
      end

      # to_save will never be called for this strategy
    end

    ##
    # @private
    class AbstractDoSomethingWithDuplicatesStrategy
      extend Forwardable

      def_delegators :@configuration, :log

      def initialize(configuration)
        @configuration = configuration
        @fk_index = configuration.foreign_key_index
      end

      def duplicate?(record)
        @fk_index.seen?(record.class, record.key.first)
      end
    end

    ##
    # @private
    class IgnoreDuplicatesStrategy < AbstractDoSomethingWithDuplicatesStrategy
      def to_save(duplicate_record)
        nil
      end
    end

    ##
    # @private
    class ReplaceDuplicatesStrategy < AbstractDoSomethingWithDuplicatesStrategy
      def to_save(duplicate_record)
        log.info "Updating duplicate record #{duplicate_record.class}##{duplicate_record.key.first}"

        reloaded = duplicate_record.class.get(*duplicate_record.key)

        duplicate_record.class.properties.each do |prop|
          reloaded[prop.name] = duplicate_record[prop.name]
        end

        reloaded
      end
    end
  end
end
