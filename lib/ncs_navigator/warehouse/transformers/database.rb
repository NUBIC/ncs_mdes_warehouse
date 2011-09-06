require 'ncs_navigator/warehouse'

require 'active_support/core_ext/string'

module NcsNavigator::Warehouse::Transformers
  module Database
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
    end
  end
end
