require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe CodedAsMissingFilter, :use_mdes do
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

    shared_context 'with blanks' do
      describe 'with blanks' do
        it 'nils a blank foreign key' do
          records = [
            mdes_model(:Person).new(:person_id => '4', :new_address_id => "\t")
          ]

          call(records).first.new_address_id.should be_nil
        end

        it 'leaves other blank values alone' do
          records = [
            mdes_model(:Person).new(:person_id => '4', :first_name => "  \n")
          ]

          call(records).first.first_name.should == "  \n"
        end
      end
    end

    describe '.call' do
      def call(records)
        CodedAsMissingFilter.call(records)
      end

      %w(-3 -4 -6 -7).each do |bad_code|
        it_filters_missing_code(bad_code)
      end

      include_context 'with blanks'
    end

    describe '#call' do
      def call(records)
        CodedAsMissingFilter.new(spec_config).call(records)
      end

      %w(-3 -4 -6 -7).each do |bad_code|
        it_filters_missing_code(bad_code)
      end

      include_context 'with blanks'
    end
  end
end
