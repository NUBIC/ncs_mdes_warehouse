require 'nokogiri'
require 'time'

class MdesLoader
  attr_reader :path

  def initialize(mdes_xml_path)
    @path = mdes_xml_path
  end

  def m
    NcsNavigator::Warehouse::Models::TwoPointZero
  end

  def good
    @good ||= []
  end

  def bad
    @bad ||= []
  end

  def load!
    $stderr.puts "Reading #{path}"
    @start = Time.now
    m::StudyCenter.transaction do
      File.open(path) do |f|
        Nokogiri::XML::Reader(f).each do |node|
          # 1 is an open element
          # 15 is a close
          next unless [1, 15].include?(node.node_type)
          if self.in_table_section
            if self.current_model_class
              if node.local_name == self.current_model_class.mdes_table_name
                # on the way out
                build_current_instance!
              else
                var = node.local_name.to_sym
                val = node.inner_xml.strip
                node.read # skip contents
                node.read # skip close
                next if var == :transaction_type
                # if it's a key to another table
                if current_model_class.relationships.detect { |r| r.child_key.collect(&:name).include?(var) }
                  # and it is -3 (unknown) or blank
                  if val == '-3' || val.strip.empty?
                    $stderr.puts "Skipping fk #{var.inspect} on #{current_model_class.mdes_table_name} with value #{val.inspect}"
                    # skip it
                    next
                  end
                end
                self.current_parameter_values[var] = val
              end
            else
              if node.local_name == 'transmission_tables'
                # on the way out
                self.in_table_section = false
              else
                self.current_model_class =
                  m.mdes_order.detect { |model| model.mdes_table_name == node.local_name }
                self.current_model_class or fail "Could not find model for #{node.local_name.inspect}"
                self.current_parameter_values = {}
              end
            end
          else
            if node.local_name == 'transmission_tables'
              self.in_table_section = true
            end
          end
        end
      end
      @end = Time.now
    end

    self
  end

  def load_time
    (@end || Time.now) - @start
  end

  def load_rate
    (good.size + bad.size) / load_time.to_f
  end

  attr_accessor :in_table_section, :current_model_class, :current_parameter_values

  def clear_line
    @clear_line ||=
      begin
        cols = `tput cols`.to_i
        "\r#{' ' * cols}\r"
      end
  end

  def build_current_instance!
    instance = current_model_class.new(current_parameter_values)
    if instance.valid?
      instance.save
      self.good << instance
      $stderr.write "#{clear_line}%6d records (%3.1f per second); up to #{current_model_class.mdes_table_name}" % [good.size, load_rate]
      $stderr.flush
    else
      $stderr.puts "\nRecord for #{current_model_class.mdes_table_name} is not valid:"
      instance.errors.each do |e|
        $stderr.puts "- #{e}"
      end
      $stderr.puts "Parameters were #{current_parameter_values.inspect}"
      self.bad << instance
    end

    self.current_model_class = nil
  end
end
