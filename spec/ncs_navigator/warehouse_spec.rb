require File.expand_path('../../spec_helper', __FILE__)

module NcsNavigator
  describe Warehouse do
    before do
      # preserve the value set for other tests
      @original = Warehouse.bcdatabase
      Warehouse.bcdatabase = nil
    end

    after do
      Warehouse.bcdatabase = @original
    end

    describe '.bcdatabase' do
      it 'has a default value' do
        Warehouse.bcdatabase = nil
        Warehouse.bcdatabase.should be_a Bcdatabase::DatabaseConfigurations
      end
    end
  end
end
