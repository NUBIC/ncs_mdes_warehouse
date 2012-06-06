require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe ApplyGlobalValuesFilter, :use_mdes do
    let(:filter) {
      ApplyGlobalValuesFilter.new(spec_config, :values => { :first_name => 'Fred' })
    }

    let(:person) { get_model(:Person).new }
    let(:contact) { get_model(:Contact).new }

    def get_model(name)
      spec_config.models_module.const_get(name)
    end

    it 'applies a global value if the record has that variable and it is not set' do
      filter.call([person])
      person.first_name.should == 'Fred'
    end

    it 'does not apply a global value if the record does not have that variable' do
      lambda { filter.call([contact]) }.should_not raise_error
    end

    it 'does not apply a global value if the record already has a value for that variable' do
      person.first_name = 'Leo'
      filter.call([person])
      person.first_name.should == 'Leo'
    end

    describe 'default values' do
      it 'includes the id of the first PSU as :psu_id' do
        filter.global_values[:psu_id].should == '20000030'
      end

      it 'includes the recruitment type as :recruit_type' do
        filter.global_values[:recruit_type].should == '3'
      end

      [:psu_id, :recruit_type].each do |defaulted_var|
        it "can receive an override for #{defaulted_var.inspect} during construction" do
          ApplyGlobalValuesFilter.new(spec_config, :values => { defaulted_var => 'foo' }).
            global_values[defaulted_var].should == 'foo'
        end
      end
    end
  end
end
