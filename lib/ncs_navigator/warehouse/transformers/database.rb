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

      DataMapper.setup(repository_name, connection_parameters)
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
          NcsNavigator::Warehouse.bcdatabase[bcdatabase[:group], bcdatabase[:name]].tap do |p|
            p['adapter'] = p['datamapper_adapter'] if p['datamapper_adapter']
          end
        end
    end

    def transform
      $stderr.puts("Transform started. #{self.class.record_producers.size} producers: #{self.class.record_producers.collect(&:name).join(', ')}.")
      repository.transaction.commit do
        self.class.record_producers.each { |rp| rp.execute(self) }
        unless errors.empty?
          fail "\n#{errors.size} errors:\n- #{errors.join("\n- ")}"
        else
          $stderr.puts
        end
      end
    end

    def repository
      DataMapper.repository(repository_name)
    end

    def errors
      @errors ||= []
    end

    def append_errors(producer_name, new_errors)
      new_errors.each { |e| errors << "#{producer_name}: #{e}" }
    end

    def row_encountered(producer_name)
      self.row_count += 1
      update_message(producer_name)
    end

    def result_encountered(producer_name, record_model)
      self.record_count += 1
      update_message(producer_name)
    end

    attr_writer :row_count, :record_count

    def row_count
      @row_count ||= 0
    end

    def record_count
      @record_count ||= 0
    end

    def update_message(current_producer)
      $stderr.write("#{clear_line}#{repository_name} (in %3d / %-3d out) on %s" %
        [row_count, record_count, current_producer])
    end

    def clear_line
      @clear_line ||=
        begin
          cols = `tput cols`.to_i
          "\r#{' ' * cols}\r"
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

      def produce_records(name, query=nil, &contents)
        record_producers << RecordProducer.new(name, query, contents)
      end
    end

    class RecordProducer < Struct.new(:name, :query, :row_processor)
      def query
        super || "SELECT * FROM #{name}"
      end

      def execute(transformer)
        transformer.repository.adapter.select(self.query).each do |row|
          transformer.row_encountered(name)
          begin
            [*row_processor.call(row)].each do |rec|
              if rec.respond_to?('psu_id')
                unless rec.psu_id
                  rec.psu_id = '20000030'
                end
              end
              transformer.result_encountered(name, rec.class)
              if rec.valid?
                rec.save
              else
                transformer.append_errors(self.name,
                  rec.errors.keys.collect { |prop|
                    rec.errors[prop].collect { |e|
                      v = rec.send(prop)
                      "#{e}: #{prop}=#{v.inspect} / PK #{rec.class.key.first.name}=#{rec.key.first.inspect}"
                    }
                  }.flatten)
              end
            end
          rescue => e
            transformer.append_errors(self.name, ["#{e.class}: #{e}"])
          end
        end
      end
    end

  end
end
