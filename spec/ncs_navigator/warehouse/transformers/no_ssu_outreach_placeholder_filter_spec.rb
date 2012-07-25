require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe NoSsuOutreachPlaceholderFilter, :use_mdes do
    let(:filter) { NoSsuOutreachPlaceholderFilter.new(spec_config) }

    let(:expected_placeholder_id) { 'NO_SSU_PLACEHOLDER_PRE_MDES_2_1' }

    let(:outreach_with_ssu)     { mdes_model(:Outreach).new(:outreach_event_id => 'O', :ssu_id => 'foo') }
    let(:outreach_without_ssu1) { mdes_model(:Outreach).new(:outreach_event_id => 'P') }
    let(:outreach_without_ssu2) { mdes_model(:Outreach).new(:outreach_event_id => 'E') }

    it 'filters the placeholder into appropriate outreach records only' do
      filter.call([outreach_with_ssu, outreach_without_ssu1, outreach_without_ssu2]).
        select { |o| o.class.name =~ /Outreach/ }.collect(&:ssu_id).
        should == ['foo', expected_placeholder_id, expected_placeholder_id]
    end

    it 'does not filter the placeholder into other SSU-bearing records' do
      filter.call([mdes_model(:ListingUnit).new]).first.ssu_id.should be_nil
    end

    describe 'the placeholder SSU' do
      let(:placeholder_ssu) {
        filter.call([outreach_without_ssu1]).detect { |r| r.class.name =~ /Ssu/ }
      }

      it 'is prepended in the only first call with an affected outreach event' do
        result1 = filter.call([outreach_with_ssu])
        result2 = filter.call([outreach_without_ssu1])
        result3 = filter.call([outreach_without_ssu2])

        [result1, result2, result3].
          collect { |results| results.collect { |r| r.class.name.demodulize } }.should ==
          [%w(Outreach), %w(Ssu Outreach), %w(Outreach)]
      end

      it 'has the correct ID' do
        placeholder_ssu.ssu_id.should == expected_placeholder_id
      end

      it 'has an explanatory name' do
        placeholder_ssu.ssu_name.
          should == 'Placeholder SSU for no-SSU outreach events until upgraded to MDES 2.0'
      end

      it 'has the correct PSU' do
        placeholder_ssu.psu_id.should == '20000030'
      end

      it 'has the correct SC' do
        placeholder_ssu.sc_id.should == '20000029'
      end

      it 'is a valid instance' do
        placeholder_ssu.should be_valid
      end
    end
  end
end
