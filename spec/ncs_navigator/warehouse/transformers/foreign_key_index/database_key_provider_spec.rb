require 'spec_helper'

class NcsNavigator::Warehouse::Transformers::ForeignKeyIndex
  describe DatabaseKeyProvider, :slow, :use_mdes, :use_database, :modifies_warehouse_state do
    let(:provider) { DatabaseKeyProvider.new }
    let(:psu_model) { mdes_model(:Psu) }

    before do
      DataMapper.repository(:mdes_warehouse_working) do
        psu_model.new(:sc_id => '20000013', :psu_id => '20000054', :recruit_type => '-4').save.should be_true
      end
    end

    it 'provides the existing IDs for a model out of the working repo' do
      provider.existing_keys(psu_model).should == %w(20000054)
    end
  end
end
