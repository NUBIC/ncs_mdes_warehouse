require 'spec_helper'

module NcsNavigator::Warehouse::Filters
  describe CodedAsMissingFilter, :use_mdes do
    def call(records)
      filter.call(records)
    end

    def self.it_filters_missing_code(bad_code)
      it "removes a record whose primary key is #{bad_code.inspect}" do
        records = [
          mdes_model(:Person).new(:person_id => bad_code),
          mdes_model(:Person).new(:person_id => '23')
        ]

        call(records).collect(&:person_id).should == %w(23)
      end

      it "clears a non-coded, non-required variable whose entire value is #{bad_code.inspect}" do
        records = [
          mdes_model(:StudyCenter).new(:sc_id => '2000029', :comments => bad_code)
        ]

        call(records).first.comments.should be_nil
      end

      it "clears a foreign key whose value is #{bad_code.inspect}" do
        records = [
          mdes_model(:Person).new(:person_id => '4', :new_address_id => bad_code)
        ]

        call(records).first.new_address_id.should be_nil
      end

      it "leaves alone a coded variable whose value is #{bad_code.inspect}" do
        records = [
          mdes_model(:Person).new(:person_id => '4', :sex => bad_code)
        ]

        call(records).first.sex.should == bad_code
      end
    end

    describe '.call' do
      let(:filter) { CodedAsMissingFilter }

      %w(-3 -4 -6 -7).each do |bad_code|
        it_filters_missing_code(bad_code)
      end
    end

    describe '#call' do
      let(:filter) { CodedAsMissingFilter.new(spec_config) }

      %w(-3 -4 -6 -7).each do |bad_code|
        it_filters_missing_code(bad_code)
      end

      describe 'with additional codes' do
        let(:filter) { CodedAsMissingFilter.new(spec_config, :additional_codes => %w(-47)) }

        %w(-3 -4 -47 -6 -7).each do |bad_code|
          it_filters_missing_code(bad_code)
        end
      end
    end
  end
end
