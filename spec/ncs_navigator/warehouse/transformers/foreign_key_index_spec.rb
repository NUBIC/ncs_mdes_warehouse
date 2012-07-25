require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe ForeignKeyIndex, :modifies_warehouse_state do
    class Addr
      include ::DataMapper::Resource

      property :psu_id, String
      property :id, Integer, :key => true

      belongs_to :old_one, self, :child_key => [ :old_one_id ]
      belongs_to :frob, 'NcsNavigator::Warehouse::Transformers::Frob', :child_key => [ :frob_id ]
    end

    class Frob
      include ::DataMapper::Resource

      property :psu_id, String
      property :id, Integer, :key => true
    end

    before(:each) do
      DataMapper.finalize
    end

    let(:fk_index) { ForeignKeyIndex.new(:existing_key_provider => key_provider) }
    let(:key_provider) { ForeignKeyIndex::StaticKeyProvider.new(Addr.to_s => [120, 180]) }
    let(:transform_status) { NcsNavigator::Warehouse::TransformStatus.memory_only('test') }
    let(:errors) { transform_status.transform_errors }

    describe '#initialize' do
      describe ':existing_key_provider' do
        it 'defaults to a database provider' do
          ForeignKeyIndex.new.existing_key_provider.should be_a ForeignKeyIndex::DatabaseKeyProvider
        end

        it 'uses the provided instance' do
          fk_index.existing_key_provider.should be key_provider
        end

        it 'disables existing key resolution when set to nil explicitly' do
          provider = ForeignKeyIndex.new(:existing_key_provider => nil).existing_key_provider
          provider.existing_keys(Addr).should be_nil
        end
      end
    end

    describe 'reporting errors' do
      before do
        fk_index.record_and_verify(Frob.new(:id => 8))
        fk_index.record_and_verify(Frob.new(:id => 16))
      end

      it 'does not report for a key which is satisfied when it is first recorded' do
        fk_index.record_and_verify(Addr.new(:frob_id => 8, :id => 1))
        fk_index.report_errors(transform_status)

        errors.should == []
      end

      it 'does not report for a key which is not initially satisfied but is later' do
        fk_index.record_and_verify(Addr.new(:frob_id => 4, :id => 1))
        fk_index.record_and_verify(Frob.new(:id => 4))
        fk_index.report_errors(transform_status)

        errors.should == []
      end

      it 'does not report for a key which is provided by the external key provider' do
        fk_index.record_and_verify(Addr.new(:id => 8, :old_one_id => 120))
        fk_index.report_errors(transform_status)

        errors.should == []
      end

      describe 'when a key is never satisfied' do
        before do
          fk_index.record_and_verify(Addr.new(:frob_id => 4, :id => 1))
          fk_index.report_errors(transform_status)
        end

        it 'reports the error' do
          errors.size.should == 1
        end

        it 'includes the correct model_class' do
          errors.first.model_class.should == Addr.to_s
        end

        it 'includes the correct record_id' do
          errors.first.record_id.should == '1'
        end

        it 'includes a useful message' do
          errors.first.message.should ==
            'Unsatisfied foreign key frob_id=4 referencing NcsNavigator::Warehouse::Transformers::Frob.'
        end

        it 'only reports the error once if #report_errors is called multiple times' do
          fk_index.report_errors(transform_status)

          errors.size.should == 1
        end
      end

      it 'reports multiple failed references for a single record' do
        fk_index.record_and_verify(Addr.new(:id => 1, :frob_id => 2, :old_one_id => 3))
        fk_index.report_errors(transform_status)

        errors.collect { |e| e.message.match(/foreign key (\S+)/)[1] }.sort.should ==
          %w(frob_id=2 old_one_id=3)
      end
    end
  end
end
