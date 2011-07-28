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

        property   :tableau_id, NcsNavigator::Warehouse::DataMapper::NcsString, :key => true
        property   :age_span,
                   NcsNavigator::Warehouse::DataMapper::NcsString,
                   :set => %w(1-9 10-18 19-54), :pii => :possible
        belongs_to :context, 'NcsNavigator::Warehouse::Models::Spec::Sample::Context',
                   :child_key => [ :context_id ]
        property   :ssn, NcsNavigator::Warehouse::DataMapper::NcsString, :pii => true

        mdes_order :tableau_id, :age_span, :context_id, :ssn
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
          should == [ :tableau_id, :age_span, :context_id, :ssn ]
      end
    end

    describe '#write_mdes_xml' do
      require 'pp'

      subject {
        Spec::Sample::GenerationalTableau.new(
          :tableau_id => 4, :age_span => '19-54', :ssn => '555-45-4444'
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
        xml.root.elements.size.should == 3
      end

      it 'produces XML omitting PII by default' do
        xml.xpath('//ssn').should be_empty
      end

      it 'emits :possible PII columns when omitting PII' do
        xml.xpath('//age_span').should_not be_empty
      end

      it 'emits the columns according to the mdes_order' do
        xml.root.elements.collect(&:name).should == %w(tableau_id age_span context_id)
      end

      it 'emits PII columns if requested' do
        subject.write_mdes_xml(io, :pii => true)
        Nokogiri::XML(io.string).root.elements.collect(&:name).
          should == %w(tableau_id age_span context_id ssn)
      end

      it 'emits the property values as expected' do
        xml.xpath('//age_span').first.text.strip.should == '19-54'
      end

      it 'skips properties which are nil' do
        subject.age_span = nil
        xml.xpath('//age_span').should be_empty
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

        it 'escapes illegal elements' do
          subject.age_span = '4 & 8'
          xml_string.should include('4 &amp; 8')
        end
      end
    end
  end
end
