require 'forwardable'

module NcsNavigator::Warehouse::Transformers
  ##
  # Encapsulates an ordered list of filters that can be applied to a
  # record coming out of an enumeration in {EnumTransformer}.
  #
  # Each filter is an object with an `call` method. The `call`
  # method takes an array of zero or more records as input and returns
  # an array of zero or more records. The input and output arrays may
  # be the same or different. A filter may add, remove, or mutate
  # records (or all three).
  #
  # A filter will be called multiple times for a single transform run,
  # but it will never see the same record twice. To put it another
  # way, the first filter will be invoked exactly once per record
  # yielded from an {EnumTransformer}'s enumeration. Subsequent
  # filters are invoked on return value from the previous filter.
  #
  # Depending on the filter order, a particular filter may never see
  # some of the eventually transformed records. This will happen if
  # records are created by a filter lower in the filter chain.
  class Filters
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

