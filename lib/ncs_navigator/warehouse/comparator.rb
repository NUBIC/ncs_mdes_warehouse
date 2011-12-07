require 'ncs_navigator/warehouse'

require 'forwardable'

module NcsNavigator::Warehouse
  class Comparator
    extend Forwardable

    attr_reader :level
    attr_reader :a, :b

    def_delegators :a, :shell

    def initialize(config_a, config_b, options={})
      @a = config_a; @b = config_b
      @level = options[:level] ||= 1

      shell.clear_line_and_say "Connecting to warehouse A..."
      DatabaseInitializer.new(@a).set_up_repository(:reporting, 'a')
      shell.clear_line_and_say "Connecting to warehouse B..."
      DatabaseInitializer.new(@b).set_up_repository(:reporting, 'b')
      shell.clear_line_and_say ''
    end

    def compare
      shell.say_line "Running level #{level} compare..."
      count_diff if level >= 1
      id_diff if level >= 2
      content_diff if level >= 3
    end

    def count_diff
      @count_diffs = collect_differences(CountDiff, models.collect { |m| [m] })
      shell_summarize_differences(CountDiff, @count_diffs)
    end

    def id_diff
      @id_diffs = collect_differences(
        IdDiff, models.select { |m| no_zero_counts?(m) }.collect { |m| [m] })
      shell_summarize_differences(IdDiff, @id_diffs)
    end

    def content_diff
      @content_diffs = collect_differences(
        ContentDiff, models.collect { |m| [m, list_shared_ids(m)] }.select { |m, shared| shared })
      shell_summarize_differences(ContentDiff, @content_diffs)
    end

    private

    def models
      @models ||= begin
                    shell.clear_line_and_say "Loading MDES models..."
                    a.models_module.mdes_order
                  end
    end

    def collect_differences(differ, arg_sets)
      start = Time.now
      arg_sets.collect do |arg_set|
        model = arg_set.first
        shell.clear_line_and_say "comparing #{differ.thing_plural} for #{model.mdes_table_name}..."
        differ.new(*arg_set).compare
      end.compact.tap {
        shell.clear_line_and_say "#{differ.thing} comparisons complete in %.1fs.\n" % (Time.now - start)
      }
    end

    def shell_summarize_differences(differ, diffs)
      if diffs.empty?
        puts "There are no #{differ.thing} differences."
      else
        puts "#{differ.thing_plural} differ in #{diffs.size} table#{'s' if diffs.size != 1}:"
        diffs.each do |diff|
          puts diff.shell_summary
        end
      end
      puts
    end

    def no_zero_counts?(model)
      if diff = @count_diffs.find { |d| d.table_name == model.mdes_table_name }
        diff.a_count != 0 && diff.b_count != 0
      else
        true
      end
    end

    def list_shared_ids(model)
      if diff = @id_diffs.find { |d| d.model == model }
        diff.shared
      else
        nil
      end
    end

    # @private
    class CountDiff
      attr_reader :table_name, :a_count, :b_count

      def self.thing; 'count'; end
      def self.thing_plural; 'counts'; end

      def initialize(model)
        @table_name = model.mdes_table_name
        @q = "SELECT COUNT(*) FROM #{table_name}"
      end

      def compare
        @a_count = count('a_reporting')
        @b_count = count('b_reporting')
        if difference != 0
          self
        end
      end

      def difference
        a_count - b_count
      end

      def count(repo)
        ::DataMapper.repository(repo).adapter.select(@q).first
      end

      def shell_summary
        "  %30s: A = %6d %s %-6d = B | %6d" % [
          table_name,
          a_count, a_count > b_count ? '>' : '<', b_count,
          difference.abs
        ]
      end
    end

    # @private
    class IdDiff
      attr_reader :model, :a_ids, :b_ids

      def self.thing; 'ID'; end
      def self.thing_plural; 'IDs'; end

      def initialize(model)
        @model = model
        @q = "SELECT #{model.key.first.name} FROM #{model.mdes_table_name}"
      end

      def compare
        @a_ids = ids('a_reporting')
        @b_ids = ids('b_reporting')
        unless a_only.empty? && b_only.empty?
          self
        end
      end

      def a_only
        @a_only ||= a_ids - b_ids
      end

      def b_only
        @b_only ||= b_ids - a_ids
      end

      def shared
        @shared ||= a_ids & b_ids
      end

      def ids(repo)
        ::DataMapper.repository(repo).adapter.select(@q)
      end

      def shell_summary
        [
          "  #{model.mdes_table_name}",
         ("    #{a_only.size} in A only: #{a_only.join(', ')}" unless a_only.empty?),
         ("    #{b_only.size} in B only: #{b_only.join(', ')}" unless b_only.empty?),
          "    #{shared.size} the same in both A and B."
        ].compact.join("\n")
      end
    end

    # @private
    class ContentDiff
      BLOCK_SIZE = 5000

      attr_reader :model, :shared_ids

      def self.thing; 'content'; end
      def self.thing_plural; 'contents'; end

      def initialize(model, shared_ids)
        @model = model
        @shared_ids = shared_ids
      end

      def compare
        id_blocks.each do |ids|
          key = model.key.first.name
          ids_param = "'#{ids.join("', '")}'"
          find_all = lambda { |repo_name|
            q = "SELECT * FROM #{model.mdes_table_name} WHERE #{key} IN (#{ids_param}) ORDER BY #{key}"
            ::DataMapper.repository(repo_name).adapter.select(q)
          }
          a_records = find_all['a_reporting']
          b_records = find_all['b_reporting']

          a_records.zip(b_records).each do |a_rec, b_rec|
            compare_records(a_rec[key], a_rec, b_rec)
          end
        end

        unless differences.empty?
          self
        end
      end

      def differences
        @differences ||= {}
      end

      def id_blocks
        @id_blocks ||=
          begin
            allocated = 0
            blocks = []
            while allocated < shared_ids.size
              blocks << shared_ids[allocated...(allocated + BLOCK_SIZE)]
              allocated += BLOCK_SIZE
            end
            blocks
          end
      end

      def compare_records(id, a_record, b_record)
        rec_diff = a_record.members.inject({}) { |h, prop|
          a_value = a_record.send(prop)
          b_value = b_record.send(prop)
          h[prop] = [a_value, b_value] if a_value != b_value
          h
        }
        unless rec_diff.empty?
          differences[id] = rec_diff
        end
      end

      def shell_summary
        [
          "  #{model.mdes_table_name}:",
          differences.each_pair.collect do |id, rec_diff|
            ["    #{id}:"] +
              rec_diff.each_pair.collect { |var, vals|
                "      #{var}: #{vals.collect(&:inspect).join(' != ')}"
              }
          end
        ].flatten.join("\n")
      end
    end
  end
end
