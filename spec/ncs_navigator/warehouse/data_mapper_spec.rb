require 'spec_helper'

module NcsNavigator::Warehouse::DataMapper
  shared_examples 'a string-based NCS type' do
    it 'converts a BigDecimal to a simple number string (no powers of ten)' do
      subject.send(:typecast_to_primitive, BigDecimal.new('0.453E1')).should == '4.53'
    end

    it 'uses the default method for other types' do
      subject.send(:typecast_to_primitive, 45).should == '45'
    end

    it 'is not lazily-loaded' do
      subject.options[:lazy].should be_false
    end
  end

  describe NcsString, :modifies_warehouse_state do
    let(:model) {
      class NcsStringHost
        include DataMapper::Resource
        property :haiku, NcsString
      end
    }

    subject { model.properties[:haiku] }

    it_behaves_like 'a string-based NCS type'
  end

  describe NcsText, :modifies_warehouse_state do
    let(:model) {
      class NcsTextHost
        include DataMapper::Resource
        property :novel, NcsText
      end
    }

    subject { model.properties[:novel] }

    it_behaves_like 'a string-based NCS type'
  end

  describe NcsInteger, :modifies_warehouse_state do
    let(:model) {
      class NcsintegerHost
        include DataMapper::Resource
        property :code, NcsInteger
      end
    }

    let(:prop) { model.properties[:code] }

    it 'can be set from a canonical string' do
      prop.send(:typecast_to_primitive, '46').should == 46
    end

    it 'can be set from a Fixnum' do
      prop.send(:typecast_to_primitive, 50).should == 50
    end

    it 'converts to an integer even if there are leading zeros' do
      prop.send(:typecast_to_primitive, '037').should == 37
    end

    it 'does not convert to an integer if it is a non-numeric string' do
      prop.send(:typecast_to_primitive, 'abc123').should == 'abc123'
    end
  end
end
