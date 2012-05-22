require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe SamplingUnits, :use_mdes, :slow do
    subject { SamplingUnits.new(spec_config) }

    let(:test_sc_id) { '20000029' }
    let(:test_psu_id) { '20000030' }

    describe '.create_transformer' do
      it 'creates a transformer' do
        SamplingUnits.create_transformer(spec_config).should respond_to(:transform)
      end
    end

    it 'yields everything in MDES order' do
      subject.to_a.collect { |i| i.class.to_s.demodulize }.should == %w(StudyCenter Psu Ssu Ssu Tsu)
    end

    describe 'emitted Study Center' do
      let(:sc_model) { spec_config.models_module.const_get(:StudyCenter) }
      let(:sc) { subject.to_a.detect { |emitted| emitted.is_a?(sc_model) } }

      it 'exists' do
        sc.should_not be_nil
      end

      it 'has the study center ID from the configuration' do
        sc.sc_id.should == test_sc_id
      end

      it 'has the name from the MDES' do
        sc.sc_name.should == 'Northwestern University'
      end

      it 'has no comments' do
        sc.comments.should be_nil
      end
    end

    describe 'emitted PSU' do
      let(:psu_model) { spec_config.models_module.const_get(:Psu) }
      let(:psu) { subject.to_a.detect { |emitted| emitted.is_a?(psu_model) } }

      it 'exists' do
        psu.should_not be_nil
      end

      it 'has the study center ID from the configuration' do
        psu.sc_id.should == test_sc_id
      end

      it 'has the correct ID' do
        psu.psu_id.should == test_psu_id
      end

      it 'has the name derived from the MDES' do
        psu.psu_name.should == 'Cook County, IL (Wave 1)'
      end

      it 'uses the recruitment type from the configuration' do
        psu.recruit_type.should == '3'
      end
    end

    describe 'emitted SSU set' do
      let(:ssu_model) { spec_config.models_module.const_get(:Ssu) }
      let(:ssus) { subject.to_a.select { |emitted| emitted.is_a?(ssu_model) } }

      it 'includes all the SSUs from the configuration' do
        ssus.collect(&:ssu_id).sort.should == %w(24 42)
      end

      describe 'an exemplar' do
        let(:ssu) { ssus.detect { |s| s.ssu_id == '42' } }

        it 'has the name' do
          ssu.ssu_name.should == 'UPT-42'
        end

        it 'has the ID' do
          ssu.ssu_id.should == '42'
        end

        it 'has the SC ID' do
          ssu.sc_id.should == '20000029'
        end

        it 'has the PSU ID' do
          ssu.psu_id.should == test_psu_id
        end
      end
    end

    describe 'emitted TSU set' do
      let(:tsu_model) { spec_config.models_module.const_get(:Tsu) }
      let(:tsus) { subject.to_a.select { |emitted| emitted.is_a?(tsu_model) } }

      it 'includes all the TSUs from the configuration' do
        tsus.collect(&:tsu_id).sort.should == %w(42-3)
      end

      describe 'an exemplar' do
        let(:tsu) { tsus.detect { |s| s.tsu_id == '42-3' } }

        it 'has the name' do
          tsu.tsu_name.should == 'UPT-42X'
        end

        it 'has the ID' do
          tsu.tsu_id.should == '42-3'
        end

        it 'has the SC ID' do
          tsu.sc_id.should == '20000029'
        end

        it 'has the PSU ID' do
          tsu.psu_id.should == test_psu_id
        end
      end
    end
  end
end
