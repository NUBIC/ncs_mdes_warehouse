require 'forwardable'

module NcsNavigator::Warehouse::Filters
  ##
  # Encapsulates an ordered list of filters that can be applied to one or more
  # records. Filters of this type are used in {EnumTransformer} and {Contents}.
  #
  # Each filter is an object with an `call` method. The `call` method takes an
  # array of zero or more records as input and returns an array of zero or more
  # records. The input and output arrays may be the same or different. A filter
  # may add, remove, or mutate records (or all three).
  #
  # A filter will be called multiple times for a single transform run, but it
  # will never see the same record twice. To put it another way, the first
  # filter will be invoked exactly once per record yielded from the underlying
  # enumeration. Subsequent filters are invoked on the return value from the
  # previous filter.
  #
  # Depending on the filter order, a particular filter may never see some of the
  # eventually transformed records. This will happen if records are created by a
  # filter lower in the filter chain.
  #
  # Leaky abstraction note: if a filter needs to change the primary key for a
  # record, there is unfortunate DataMapper behavior to contend with. DM
  # memoizes the result of `Resource#key` after the first time it is invoked.
  # The warehouse infrastructure will certainly have invoked `#key` on a record
  # which is passed to a filter's call method. In order so that subsequent calls
  # to `#key` reflect the filter's changes, it needs to work around this. Two
  # possibilities:
  #
  # * Instead of changing the key on the passed-in record, create a new record
  #   with the new key (and all the other attributes) and return that.
  # * `record.instance_eval { remove_instance_variable(:@_key) }`
  class CompositeFilter
    include Enumerable
    extend Forwardable

    def_delegators :@filters, :each

    attr_accessor :filters

    def initialize(filter_objects)
      check_filters(filter_objects)

      @filters = filter_objects
    end

    ##
    # @param records [Array] zero or more records to filter.
    # @return [Array] the filtered records.
    def call(records)
      filters.inject(ensure_array(records)) { |result, filter| ensure_array(filter.call(result)) }
    end

    private

    def check_filters(candidates)
      candidates.each_with_index do |f, i|
        unless f.respond_to?(:call)
          fail "Filter #{i} (#{f.class}) does not have a call method"
        end
      end
    end

    def ensure_array(records)
      case records
      when nil
        []
      when Enumerable
        records.to_a
      else
        [records]
      end
    end
  end
end

