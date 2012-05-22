require 'ncs_navigator/warehouse'
require 'action_mailer'
require 'time'

module NcsNavigator::Warehouse::Hooks
  ##
  # A post-ETL hook which sends a message to configured e-mail
  # accounts after each ETL run. The message indicates whether the ETL
  # succeeded or failed and some summary statistics, but no further
  # detail.
  class EtlStatusEmail
    ##
    # @param [Hash<Symbol, Object>] options
    # @option options [Array<String>] :to the e-mail addresses to
    #   whom the notifications will be sent.
    def initialize(options={})
      @to = options[:to] or 'Need at least one recipient'
    end

    ##
    # @param [Hash<Symbol, Object>] args the arguments received from
    #   the ETL process.
    # @return [void]
    def etl_succeeded(args)
      args[:configuration].set_up_action_mailer

      Mailer.success_message(@to, args[:transform_statuses]).deliver
    end

    ##
    # @param [Hash<Symbol, Object>] args the arguments received from
    #   the ETL process.
    # @return [void]
    def etl_failed(args)
      args[:configuration].set_up_action_mailer

      Mailer.failure_message(@to, args[:transform_statuses]).deliver
    end

    ##
    # @private
    class Mailer < ::ActionMailer::Base
      self.mailer_name = 'etl_status_email'

      def success_message(to, transform_statuses)
        analyze_statuses(transform_statuses)

        mail(
          # TODO: make configurable
          :from => 'mdes-warehouse',
          :to => to,
          :subject => '[NCS Navigator] Warehouse load successful'
        )
      end

      def failure_message(to, transform_statuses)
        analyze_statuses(transform_statuses)

        mail(
          # TODO: make configurable
          :from => 'mdes-warehouse',
          :to => to,
          :subject => '[NCS Navigator] Warehouse load failed'
        )
      end

      private

      def analyze_statuses(transform_statuses)
        start_time_dt = transform_statuses.first.start_time
        end_time_dt = transform_statuses.last.end_time

        @start_time = start_time_dt.to_s

        @transform_duration = duration_string((end_time_dt - start_time_dt) * 24 * 3600)
        @transform_count = transform_statuses.size
        @record_count = transform_statuses.inject(0) { |sum, s| sum + s.record_count }

        @success_count = transform_statuses.select { |s| s.transform_errors.empty? }.size
        @failure_count = transform_statuses.size - @success_count
      end

      def duration_string(seconds)
        [ seconds / 3600, (seconds % 3600) / 60, seconds % 60 ].collect { |t| '%02d' % t }.join(':')
      end
    end
  end
end
