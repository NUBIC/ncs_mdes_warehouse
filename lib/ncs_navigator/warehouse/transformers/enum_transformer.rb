require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/data_mapper_patches'

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
    # @return [CompositeFilter] the filters in use on this transformer.
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
    # @see CompositeFilter
    def initialize(configuration, enum, options={})
      @configuration = configuration
      @enum = enum
      filter_list = options.delete(:filters)
      @filters = NcsNavigator::Warehouse::Filters::CompositeFilter.new(
        filter_list ? [*filter_list].compact : [])
      @duplicates = options.delete(:duplicates) || :error
      @duplicates_strategy = select_duplicates_strategy

      @record_checkers = {
        :validation => ValidateRecordChecker.new(log, @configuration),
        :foreign_key => ForeignKeyChecker.new(log, foreign_key_index),
        :psus => PsuIdChecker.new(log, @configuration.navigator.psus)
      }
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
      foreign_key_index.start_transform(status)
      enum.each do |record|
        case record
        when NcsNavigator::Warehouse::TransformError
          receive_transform_error(record, status)
        else
          filters.call([record]).each do |filtered_record|
            save_model_instance(filtered_record, status, [:psus, :validation, :foreign_key])
          end
        end
      end
      late_resolved_records = foreign_key_index.end_transform
      late_resolved_records.each do |record|
        save_model_instance(record, status, []) unless has_reported_errors?(record, status)
      end
    end

    ##
    # @return [void]
    def save_model_instance(incoming_record, status, record_check_kinds)
      status.record_count += 1

      record = process_duplicate_if_appropriate(incoming_record)
      unless record
        log.info("Ignoring duplicate record #{record_ident incoming_record}.")
        return
      end

      record_checks = record_check_kinds.map { |kind| @record_checkers[kind] }

      saveable = verify_record_or_report_errors(record, status, record_checks)

      if saveable
        log.debug("Saving verified record #{record_ident record}.")
        begin
          if (@configuration.soft_validations ? record.save! : record.save)
            record
            foreign_key_index.record(record)
          else
            msg = "Could not save record #{record_ident record}."
            log.error msg
            status.unsuccessful_record(record, msg)
          end
        rescue => e
          msg = "Error on save. #{e.class}: #{e}."
          log.error msg
          status.unsuccessful_record(record, msg)
        end
      end
    end

    def receive_transform_error(error, status)
      error.id = nil
      status.transform_errors << error
    end

    def has_reported_errors?(record, status)
      status.transform_errors.any? { |error|
        error.model_class.to_s == record.class.to_s &&
          error.record_id.to_s == record.key.first.to_s
      }
    end

    module RecordIdent
      def record_ident(rec)
        # No composite keys in the MDES
        '%s %s=%s' % [
          rec.class.name.demodulize, rec.class.key.first.name, rec.key.try(:first).inspect]
      end
    end
    include RecordIdent

    ###### CHECKING FOR ERRORS IN A RECORD

    def verify_record_or_report_errors(record, status, record_checks)
      record_checks.collect { |check| check.verify_or_report_errors(record, status) }.
        reject { |r| r }.empty? # does the result contain anything that isn't truthy?
    end

    class PsuIdChecker
      include RecordIdent

      attr_reader :log

      def initialize(log, psus)
        @log = log
        @psus = psus
      end

      ##
      # Has valid PSU is true if:
      #  * The record has no PSU reference, or
      #  * The record's PSU ID is one of those configured for the
      #    study center
      def has_valid_psu?(record)
        if record.respond_to?(:psu_id)
          @psus.collect(&:id).include?(record.psu_id)
        else
          true
        end
      end

      def verify_or_report_errors(record, status)
        if has_valid_psu?(record)
          true
        else
          msg = "Invalid PSU ID. The list of valid PSU IDs for this Study Center is #{@psus.collect(&:id).inspect}."
          log.error "#{record_ident record}: #{msg}"
          status.unsuccessful_record(record, msg,
            :attribute_name => 'psu_id',
            :attribute_value => record.psu_id.inspect)
          false
        end
      end
    end

    class ValidateRecordChecker
      include RecordIdent

      attr_reader :log

      def initialize(log, configuration)
        @log = log
        @configuration = configuration
      end

      def verify_or_report_errors(record, status)
        if record.valid?
          log.debug "#{record_ident record} is valid."
          true
        else
          log.error "#{record_ident record} is not valid. #{record_messages(record).join(' ')}"
          record.errors.keys.each do |prop|
            record.errors[prop].each do |e|
              status.unsuccessful_record(
                record, "Invalid: #{e}.",
                :attribute_name => prop,
                :attribute_value => record.send(prop).inspect
              )
            end
          end
          @configuration.soft_validations
        end
      end

      def record_messages(record)
        record.errors.keys.collect { |prop|
          record.errors[prop].collect { |e|
            v = record.send(prop)
            "#{e} (#{prop}=#{v.inspect})."
          }
        }.flatten
      end
    end

    class ForeignKeyChecker
      include RecordIdent

      attr_reader :log, :fk_index

      def initialize(log, fk_index)
        @log = log
        @fk_index = fk_index
      end

      def verify_or_report_errors(record, status)
        log.debug "Verifying FKs for #{record_ident record}"
        fk_index.verify_or_defer(record).tap do |result|
          if result
            log.debug "- All FKs currently resolved."
          else
            log.debug "- Deferring because one or more FKs are not resolved."
          end
        end
      end
    end

    ###### HANDLING DUPLICATES

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
