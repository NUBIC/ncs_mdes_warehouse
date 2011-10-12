require File.expand_path('../../spec_helper', __FILE__)

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

    describe '.default_bcdatabase_group' do
      before do
        clear_warehouse_state
      end

      subject { Warehouse.default_bcdatabase_group }

      [
        %w(local_postgresql development),
        %w(public_ci_postgresql9 ci),
        %w(ncsdb_staging staging),
        %w(ncsdb_prod production),
      ].collect { |exp, env| [exp.to_sym, env] }.each do |expected, environment|
        it "is #{expected} for #{environment}" do
          Warehouse.env = environment
          subject.should == expected
        end
      end

      it 'throws an exception for an unknown environment' do
        Warehouse.env = 'the_moon'
        lambda { subject }.should raise_error(/unknown environment the_moon/i)
      end
    end

  end
end
