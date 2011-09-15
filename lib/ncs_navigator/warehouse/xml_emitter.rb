require 'ncs_navigator/warehouse'

require 'ncs_navigator/configuration'
require 'erb'
require 'zip/zip'
require 'pathname'
require 'fileutils'

module NcsNavigator::Warehouse
  class XmlEmitter
    attr_reader :filename

    HEADER_TEMPLATE = ERB.new(<<-XML_ERB)
<?xml version="1.0" encoding="UTF-8" ?>
<!--
  This document was generated by
  NCS Navigator MDES Warehouse #{NcsNavigator::Warehouse::VERSION}
-->
<ncs:recruitment_substudy_transmission_envelope
  xmlns:ncs="http://www.nationalchildrensstudy.gov"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  >
<ncs:transmission_header>
<sc_id><%= sc_id %></sc_id>
<psu_id><%= psu_id %></psu_id>
<specification_version><%= specification_version %></specification_version>
<is_snapshot>true</is_snapshot>
</ncs:transmission_header>
<ncs:transmission_tables>
XML_ERB

    FOOTER_TEMPLATE = <<-XML
</ncs:transmission_tables>
</ncs:recruitment_substudy_transmission_envelope>
XML

    def initialize(filename, options={})
      @filename = Pathname === filename ? filename : Pathname.new(filename.to_s)
    end

    def emit_xml
      filename.open('w') do |f|
        f.write HEADER_TEMPLATE.result(binding)

        NcsNavigator::Warehouse.models_module.mdes_order.each do |model|
          write_all_xml_for_model(f, model)
        end

        f.write FOOTER_TEMPLATE
      end

      FileUtils.cd filename.dirname do
        Zip::ZipFile.open(filename.basename.to_s + '.zip', Zip::ZipFile::CREATE) do |zf|
          zf.add(filename.basename, filename.basename)
        end
      end
    end

    private

    def write_all_xml_for_model(f, model)
      model.all.each do |instance|
        instance.write_mdes_xml(f, :indent => 3, :margin => 1)
      end
    end

    def sc_id
      NcsNavigator.configuration.sc_id
    end

    def psu_id
      NcsNavigator.configuration.psus.first.id
    end

    def specification_version
      NcsNavigator::Warehouse.mdes.specification_version
    end
  end
end
