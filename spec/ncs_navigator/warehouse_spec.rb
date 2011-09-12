require File.expand_path('../../spec_helper', __FILE__)

module NcsNavigator
  describe Warehouse do
    before do
      # clear for testing
      @original_wh_env, Warehouse.env = Warehouse.env, nil
      @original_env_var, ENV['NCS_NAVIGATOR_ENV'] = ENV['NCS_NAVIGATOR_ENV'], nil
    end

    after do
      ENV['NCS_NAVIGATOR_ENV'] = @original_env_var
      Warehouse.env = @original_wh_env
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
      before do
        # preserve the value set for other tests
        @original = Warehouse.bcdatabase
        Warehouse.bcdatabase = nil
      end

      after do
        Warehouse.bcdatabase = @original
      end

      it 'has a default value' do
        Warehouse.bcdatabase = nil
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

    describe '.use_mdes_version' do
      context 'for a known version' do
        after(:all) do
          reset_models
          Warehouse.mdes = nil
        end

        let!(:subject) { Warehouse.use_mdes_version('2.0') }

        it 'makes the models available' do
          ::DataMapper::Model.descendants.to_a.size.should == 264
        end

        it 'returns the module' do
          subject.name.should == 'NcsNavigator::Warehouse::Models::TwoPointZero'
        end

        it 'makes the MDES specification available' do
          Warehouse.mdes.version.should == '2.0'
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
    end
  end
end
