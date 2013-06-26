require 'spec_helper'

require 'ncs_navigator/warehouse/data_mapper'

module NcsNavigator::Warehouse::Transformers
  describe EnumTransformer do
    describe '#transform' do
      context 'soft_validations', :use_database, :modifies_warehouse_state do

        class Sample
          include ::DataMapper::Resource

          property :psu_id, String
          property :recruit_type, String, :format => /^\d$/
          property :id, Integer, :key => true
          property :name, String, :required => true
        end

        before(:all) do
          DataMapper.finalize
        end

        let(:records) {[Sample.new(:id => 1, :psu_id => '20000030', :name => 'One'),
                        Sample.new(:id => 2, :psu_id => '20000030', :name => 'Two'),
                        Sample.new(:id => 3, :psu_id => '20000030', :name => 'Three')
                       ]}
        let(:transformer) { EnumTransformer.new(spec_config.tap{|c|c.soft_validations = true}, records) }
        let(:transform_status) { NcsNavigator::Warehouse::TransformStatus.memory_only('test') }

        it 'saves invalid records but still records validation errors' do
          records[2].recruit_type = 'H'
          records[2].dirty?.should == true
          records[2].valid?.should == false
          transformer.transform(transform_status)
          transform_status.transform_errors.size.should == 1
          records[2].dirty?.should == false
        end

        context "in combination with drop_all_null_constraints" do

          around(:each) do |ex|
            NcsNavigator::Warehouse::Spec.database_initializer.replace_schema
            ex.run
            NcsNavigator::Warehouse::Spec.database_initializer.replace_schema
          end

          it 'saves null records with drop_all_null_constraints' do
            NcsNavigator::Warehouse::Spec.database_initializer.drop_all_null_constraints(:working)
            records[2].name = nil
            records[2].dirty?.should == true
            records[2].valid?.should == false
            transformer.transform(transform_status)
            transform_status.transform_errors.size.should == 1
            records[2].dirty?.should == false
          end
        end
      end
    end
  end
end
