require 'ncs_navigator/warehouse'

class XmlEmitter
  def initialize(filename)
    @filename = filename
    @record_ct = 0

    @head, @foot = XML_BOILERPLATE.split(/\s*=========\s*/, 2)
  end

  def m
    NcsNavigator::Warehouse::Models::TwoPointZero
  end

  def emit!
    $stderr.puts "Writing #{@filename}"
    @start = Time.now
    File.open(@filename, 'w') do |f|
      f.puts @head

      m.mdes_order.each { |model|
        $stderr.write("#{clear_line}Writing XML for %33s" % model.mdes_table_name)
        $stderr.flush
        write_all_data_for_model(f, model)
      }

      f.puts @foot
    end
    @end = Time.now
    $stderr.puts("#{clear_line}%d records written in %d seconds (%.1f/sec)." %
      [@record_ct, write_time, write_rate])
    zipped_name = @filename + '.zip'
    system("zip -v -D -FS '#{zipped_name}' '#{@filename}'")

    # TODO: Schema validation
  end

  def write_all_data_for_model(f, model)
    $stderr.write(' %20s' % '[loading]')
    model.all.each do |instance|
      instance.write_mdes_xml(f, :indent => 3, :margin => 1)
      @record_ct += 1
      $stderr.write("#{"\b" * 20}%20s" % ("%5d (%5.1f/sec)" % [@record_ct, write_rate]))
      $stderr.flush
    end
  end

  def clear_line
    @clear_line ||=
      begin
        cols = `tput cols`.to_i
        "\r#{' ' * cols}\r"
      end
  end

  def write_time
    ((@end || Time.now) - @start)
  end

  def write_rate
    @record_ct / write_time
  end
end

XML_BOILERPLATE = <<-XML
<?xml version="1.0" encoding="UTF-8" ?>
<!-- This document was generated by NCS Navigator -->
<ncs:recruitment_substudy_transmission_envelope
  xmlns:ncs="http://www.nationalchildrensstudy.gov"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  >
<ncs:transmission_header>
<sc_id>20000029</sc_id>
<psu_id>20000030</psu_id>
<specification_version>2.0.01.02</specification_version>
<is_snapshot>true</is_snapshot>
</ncs:transmission_header>
<ncs:transmission_tables>

=========

</ncs:transmission_tables>
</ncs:recruitment_substudy_transmission_envelope>
XML

if __FILE__ == $0
  require File.expand_path('../db_initializer', __FILE__)
  DatabaseInitializer.new

  XmlEmitter.new('cook-20110802.xml').emit!
end