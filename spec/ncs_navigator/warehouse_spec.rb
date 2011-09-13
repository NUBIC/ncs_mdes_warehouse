require File.expand_path('../../spec_helper', __FILE__)

module NcsNavigator
  describe Warehouse, :modifies_warehouse_state  do
    before do
      clear_warehouse_state
    end

    describe '.env' do
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
      it 'has a default value' do
        Warehouse.bcdatabase.should be_a Bcdatabase::DatabaseConfigurations
      end
    end

    describe '.default_bcdatabase_group' do
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

    describe '.use_mdes_version', :slow do
      context 'for a known version' do
        let!(:subject) { Warehouse.use_mdes_version(spec_mdes_version) }

        it 'makes the models available' do
          ::DataMapper::Model.descendants.
            collect { |m| m.name.demodulize }.should include('Address')
        end

        it 'returns the module' do
          subject.name.should =~ /^NcsNavigator::Warehouse::Models::\w+$/
        end

        it 'makes the MDES specification available' do
          Warehouse.mdes.version.should == spec_mdes_version
        end

        it 'makes the models module available' do
          Warehouse.models_module.name.should =~ /^NcsNavigator::Warehouse::Models::\w+$/
        end
      end

      it 'throws an exception for an unknown version' do
        lambda { Warehouse.use_mdes_version('42.42') }.
          should raise_error /No warehouse models exist for MDES version 42.42/
      end
    end

    describe '.mdes' do
      it 'throws an exception when called before use_mdes_version' do
        lambda { Warehouse.mdes }.
          should raise_error(/Call use_mdes_version first to select an MDES version/)
      end

      # see above for positive test
    end

    describe '.models_module' do
      it 'throws an exception when called before use_mdes_version' do
        lambda { Warehouse.models_module }.
          should raise_error(/Call use_mdes_version first to load the models/)
      end

      # see above for positive test
    end
  end
end
