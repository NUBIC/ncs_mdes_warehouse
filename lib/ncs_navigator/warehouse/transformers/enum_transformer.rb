require 'ncs_navigator/warehouse'

module NcsNavigator::Warehouse::Transformers
  ##
  # A transformer that accepts a series of model instances in the form
  # of a ruby Enumerable. An enumerable might be as simple as an
  # array, or it might be a custom class that streams through
  # thousands of instances without having them all in memory at once.
  class EnumTransformer
    attr_reader :enum

    def initialize(enum)
      @enum = enum
    end

    def transform(status)
      enum.each do |record|
        if record.valid?
          begin
            unless record.save
              status.unsuccessful_record(
                record, "Could not save. #{record_ident(record)}.")
            end
          rescue => e
            status.unsuccessful_record(
              record, "Error on save. #{e.class}: #{e}. #{record_ident(record)}.")
          end
        else
          messages = record.errors.keys.collect { |prop|
            record.errors[prop].collect { |e|
              v = record.send(prop)
              "#{e} (#{prop}=#{v.inspect})."
            }
          }.flatten
          status.unsuccessful_record(
            record, "Invalid record. #{messages.join(' ')} #{record_ident(record)}.")
        end
      end
    end

    private

    def record_ident(rec)
      # No composite keys in the MDES
      '%s %s=%s' % [rec.class.name.demodulize, rec.class.key.first.name, rec.key.first.inspect]
    end
  end
end
