require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe CodedAsMissingFilter, :use_mdes do
    describe '.call' do
      def call(records)
        CodedAsMissingFilter.call(records)
      end

      def get_model(name)
        spec_config.models_module.const_get(name)
      end

      %w(-3 -4 -6 -7).each do |bad_code|
        it "removes a record whose primary key is #{bad_code.inspect}" do
          records = [
            get_model(:Person).new(:person_id => bad_code),
            get_model(:Person).new(:person_id => '23')
          ]

          call(records).collect(&:person_id).should == %w(23)
        end

        it "clears a non-coded, non-required variable whose entire value is #{bad_code.inspect}" do
          records = [
            get_model(:StudyCenter).new(:sc_id => '2000029', :comments => bad_code)
          ]

          call(records).first.comments.should be_nil
        end

        it "clears a foreign key whose value is #{bad_code.inspect}" do
          records = [
            get_model(:Person).new(:person_id => '4', :new_address_id => bad_code)
          ]

          call(records).first.new_address_id.should be_nil
        end

        it "leaves alone a coded variable whose value is #{bad_code.inspect}" do
          records = [
            get_model(:Person).new(:person_id => '4', :sex => bad_code)
          ]

          call(records).first.sex.should == bad_code
        end
      end

      describe 'with blanks' do
        it 'nils a blank foreign key' do
          records = [
            get_model(:Person).new(:person_id => '4', :new_address_id => "\t")
          ]

          call(records).first.new_address_id.should be_nil
        end

        it 'leaves other blank values alone' do
          records = [
            get_model(:Person).new(:person_id => '4', :first_name => "  \n")
          ]

          call(records).first.first_name.should == "  \n"
        end
      end
    end
  end
end
