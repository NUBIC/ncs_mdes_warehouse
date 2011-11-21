require File.expand_path('../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse::DataMapper
  shared_examples 'a string-based NCS type' do
    it 'converts a BigDecimal to a simple number string (no powers of ten)' do
      subject.send(:typecast_to_primitive, BigDecimal.new('0.453E1')).should == '4.53'
    end

    it 'uses the default method for other types' do
      subject.send(:typecast_to_primitive, 45).should == '45'
    end
  end

  describe NcsString, :modifies_warehouse_state do
    class NcsStringHost
      include DataMapper::Resource
      property :haiku, NcsString
    end

    subject { NcsStringHost.properties[:haiku] }

    it_behaves_like 'a string-based NCS type'
  end

  describe NcsText, :modifies_warehouse_state do
    class NcsTextHost
      include DataMapper::Resource
      property :novel, NcsText
    end

    subject { NcsTextHost.properties[:novel] }

    it_behaves_like 'a string-based NCS type'
  end
end
