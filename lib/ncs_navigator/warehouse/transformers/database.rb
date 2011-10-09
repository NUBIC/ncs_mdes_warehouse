require 'ncs_navigator/warehouse'

require 'active_support/core_ext/string'

module NcsNavigator::Warehouse::Transformers
  module Database
    include Enumerable

    def self.included(cls)
      cls.extend ClassMethods
    end

    def initialize(options={})
      @repository_name = options.delete(:repository) || options.delete(:repository_name)
      @bcdatabase = (self.class.bcdatabase.merge(options.delete(:bcdatabase) || {}))
    end

    def repository_name
      @repository_name ||= self.class.repository_name
    end

    def bcdatabase
      @bcdatabase ||= self.class.bcdatabase
    end

    def connection_parameters
      @params ||=
        begin
          NcsNavigator::Warehouse.bcdatabase[bcdatabase[:group], bcdatabase[:name]]
        end
    end

    def repository
      @repository ||=
        begin
          ::DataMapper.setup(repository_name, connection_parameters)
          ::DataMapper.repository(repository_name)
        end
    end

    def each
      self.class.record_producers.each do |rp|
        repository.adapter.select(rp.query).each do |row|
          [*rp.row_processor.call(row)].each do |result|
            yield result
          end
        end
      end
    end

    module ClassMethods
      ##
      # @param [Symbol] repo_name the data mapper repository to use in
      #   / set-up for this transformer.
      # @return [void]
      def repository(repo_name)
        @repository_name = repo_name
      end

      def repository_name
        @repository_name ||= name.demodulize.underscore.to_sym
      end

      def bcdatabase(name_and_group={})
        if name_and_group.empty?
          @bcdatabase ||= { :group => 'local_postgresql' }
        else
          @bcdatabase = (self.bcdatabase || {}).merge(name_and_group)
        end
      end

      def record_producers
        @record_producers ||= []
      end

      def produce_records(name, options={}, &contents)
        record_producers << RecordProducer.new(name, options[:query], contents)
      end
    end

    class RecordProducer < Struct.new(:name, :query, :row_processor)
      def query
        super || "SELECT * FROM #{name}"
      end
    end
  end
end
