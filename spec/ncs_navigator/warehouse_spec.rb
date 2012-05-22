require 'spec_helper'

module NcsNavigator
  describe Warehouse, :modifies_warehouse_state  do
    describe '.env' do
      before do
        clear_warehouse_state
      end

      it 'defaults to "development"' do
        Warehouse.env.should == 'development'
      end

      it 'can be specified in the runtime environment' do
        ENV['NCS_NAVIGATOR_ENV'] = 'staging'
        Warehouse.env.should == 'staging'
      end

      it 'can be set explicitly' do
        Warehouse.env = 'prod'
        Warehouse.env.should == 'prod'
      end
    end

    describe '.bcdatabase' do
      before do
        clear_warehouse_state
      end

      it 'has a default value' do
        Warehouse.bcdatabase.should be_a Bcdatabase::DatabaseConfigurations
      end
    end
  end
end
