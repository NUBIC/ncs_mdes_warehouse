require 'spec_helper'

# These tests directly examine the generated models for the current
# SPEC_MDES_VERSION. For tests of general generation logic, see
# table_modeler_spec.

describe "Generated models for MDES #{spec_mdes_version}", :use_mdes do
  let(:models_module) { spec_config.models_module }

  it 'does not generate different models with the same name' do
    models_module.mdes_order.should == models_module.mdes_order.uniq
  end
end
