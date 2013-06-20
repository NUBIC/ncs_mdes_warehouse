require 'ncs_navigator/warehouse'

require 'forwardable'

module NcsNavigator::Warehouse::Transformers
  ##
  # This transformer finds all events without start dates and attempts
  # to set them from the earliest associated contact.
  class EventStartFromContactTransformer
    extend Forwardable
    attr_reader :configuration

    def_delegators :@configuration, :log, :shell

    def initialize(configuration)
      @configuration = configuration
    end

    ##
    # Implements this transformer's behavior.
    #
    # @param [TransformStatus] status
    # @return [void]
    def transform(status)
      configuration.model(:Event).all(:event_start_date.like => '9%').each do |event|
        candidates = ::DataMapper.repository.adapter.select(%Q{
          SELECT c.contact_date, c.contact_start_time
          FROM link_contact lc INNER JOIN contact c ON lc.contact_id=c.contact_id
          WHERE lc.event_id='#{event.event_id}'
          ORDER BY c.contact_date, c.contact_start_time
        })

        start_date = candidates.
          select { |dt| dt.contact_date !~ /^9/ }.collect { |dt| dt.contact_date }.uniq.first
        start_time = candidates.
          select { |dt| dt.contact_date == start_date && dt.contact_start_time !~ /^9/ }.
          collect { |dt| dt.contact_start_time }.first

        if start_date || start_time
          event.event_start_date = start_date if start_date
          event.event_start_time = start_time if start_time

          save(event, status)

          status.record_count += 1
        end
      end
    end

    private

    # TODO: share this stuff between here and EnumTransformer

    def save(record, status)
      if record.valid?
        log.debug("Saving valid transformed event record #{record_ident record}.")
        begin
          unless record.save # TODO: need to handle soft_validations here?
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
        log.error "Event invalid after transformation. #{record_messages(record).join(' ')}"
        record.errors.keys.each do |prop|
          record.errors[prop].each do |e|
            status.unsuccessful_record(
              record, "Invalid after transformation: #{e}.",
              :attribute_name => prop,
              :attribute_value => record.send(prop).inspect
              )
          end
        end
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

    def record_ident(rec)
      # No composite keys in the MDES
      '%s %s=%s' % [
        rec.class.name.demodulize, rec.class.key.first.name, rec.key.try(:first).inspect]
    end
  end
end
