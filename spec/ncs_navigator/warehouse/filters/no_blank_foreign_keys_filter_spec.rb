require 'spec_helper'

module NcsNavigator::Warehouse::Filters
  describe NoBlankForeignKeysFilter, :use_mdes do
    describe '.call' do
      def call(records)
        NoBlankForeignKeysFilter.call(records)
      end

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
  end
end
