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
          records[2].should be_dirty
          records[2].should_not be_valid
          transformer.transform(transform_status)
          transform_status.transform_errors.size.should == 1
          records[2].should_not be_dirty
        end

        context "in combination with drop_all_null_constraints" do
          before(:all) {NcsNavigator::Warehouse::Spec.database_initializer.drop_all_null_constraints(:working)}
          after (:all) {NcsNavigator::Warehouse::Spec.database_initializer.replace_schema}
          it 'saves null records with drop_all_null_constraints' do
            records[2].name = nil
            records[2].should be_dirty
            records[2].should_not be_valid
            transformer.transform(transform_status)
            transform_status.transform_errors.size.should == 1
            records[2].should_not be_dirty
          end
        end
      end
    end
  end
end
