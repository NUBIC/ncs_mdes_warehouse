require File.expand_path('../../../../spec_helper', __FILE__)

require 'data_mapper'

module NcsNavigator::Warehouse::Models
  module Spec
    ##
    # Target module for sample models
    module Sample
      def self.clear
        constants.each do |c|
          remove_const(c)
        end
      end
    end
  end

  describe MdesModel do
    before do
      class Spec::Sample::GenerationalTableau
        include ::DataMapper::Resource
        include MdesModel

        storage_names[:default] = 'generational_tableau'

        property   :tableau_id, NcsNavigator::Warehouse::DataMapper::NcsString, :key => true
        property   :age_span,
                   NcsNavigator::Warehouse::DataMapper::NcsString,
                   :set => %w(1-9 10-18 19-54 -3), :pii => :possible
        belongs_to :context, 'NcsNavigator::Warehouse::Models::Spec::Sample::Context',
                   :child_key => [ :context_id ]
        property   :ssn, NcsNavigator::Warehouse::DataMapper::NcsString,
                   :pii => true
        property   :color_scale, NcsNavigator::Warehouse::DataMapper::NcsString,
                   :pii => true,
                   :set => %w(3 4 5 6 7 8 -6)
        property   :size, NcsNavigator::Warehouse::DataMapper::NcsInteger, :omittable => true

        mdes_order :tableau_id, :age_span, :context_id, :ssn, :color_scale, :size
      end

      class Spec::Sample::Context
        include ::DataMapper::Resource
        include MdesModel

        property :context_id, NcsNavigator::Warehouse::DataMapper::NcsString, :key => true
      end

      ::DataMapper.finalize
    end

    after do
      ::DataMapper::Model.descendants.clear
      Spec::Sample.clear
    end

    describe '.mdes_order' do
      it 'is retrievable' do
        Spec::Sample::GenerationalTableau.mdes_order.
          should == [ :tableau_id, :age_span, :context_id, :ssn, :color_scale, :size ]
      end
    end

    describe '#write_mdes_xml' do
      before do
        pending 'XML generation testing does not work on JRuby' if RUBY_PLATFORM == 'java'
      end

      subject {
        Spec::Sample::GenerationalTableau.new(
          :tableau_id => 4, :age_span => '19-54', :ssn => '555-45-4444', :color_scale => '5',
          :size => 14
        ).tap do |gt|
          gt.context_id = 'AB-7833'
        end
      }

      let(:io) { StringIO.new }
      let(:xml_string) { subject.write_mdes_xml(io); io.string }
      let(:xml) { Nokogiri::XML(xml_string) }

      it 'produces XML whose root is named after the table' do
        xml.root.name.should == 'generational_tableau'
      end

      it 'emits the expected number of columns' do
        xml.root.elements.size.should == 7
      end

      it 'produces XML omitting PII by default' do
        xml.xpath('//ssn').first.text.strip.should be_empty
      end

      it 'emits :possible PII columns when omitting PII' do
        xml.xpath('//age_span').first.text.strip.should_not be_empty
      end

      it 'always emits a transaction_type entry last since the schema requires it, even though it is meaningless' do
        last = xml.root.elements.last
        last.name.should == 'transaction_type'
        last['nil'].should == 'true'
      end

      it 'emits the columns according to the mdes_order' do
        xml.root.elements.collect(&:name).
          should == %w(tableau_id age_span context_id ssn color_scale size transaction_type)
      end

      it 'emits the property values as expected' do
        xml.xpath('//age_span').first.text.strip.should == '19-54'
      end

      it 'emits blanks for properties which are nil' do
        subject.context_id = nil
        xml.xpath('//context_id').first.text.strip.should be_empty
      end

      it 'emits nothing for omittable properties which are nil' do
        subject.size = nil
        xml.xpath('//size').should be_empty
      end

      it 'emits the "unknown" value for code list properties that are nil' do
        subject.age_span = nil
        xml.xpath('//age_span').first.text.strip.should == '-3'
      end

      describe 'without PII' do
        it 'converts code list values into the "unknown" value' do
          xml.xpath('//color_scale').first.text.strip.should == '-6'
        end
      end

      describe 'when PII is requested' do
        let(:xml) {
          subject.write_mdes_xml(io, :pii => true)
          Nokogiri::XML(io.string)
        }

        it 'includes PII text values' do
          xml.xpath('//ssn').first.text.strip.should == '555-45-4444'
        end

        it 'includes PII code values' do
          xml.xpath('//color_scale').first.text.strip.should == '5'
        end
      end

      describe 'formatting' do
        it 'indents the string by default' do
          xml_string.split("\n").should include('  <age_span>19-54</age_span>')
        end

        it 'allows the indent level to be overridden' do
          subject.write_mdes_xml(io, :indent => 5)
          io.string.split("\n").should include('     <tableau_id>4</tableau_id>')
        end

        it 'accepts a base number of indents' do
          subject.write_mdes_xml(io, :margin => 4)
          io.string.split("\n").should include('        <generational_tableau>')
        end

        it 'escapes illegal characters' do
          subject.age_span = '4 & 8'
          xml_string.should include('4 &amp; 8')
        end
      end
    end
  end
end
