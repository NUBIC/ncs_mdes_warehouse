require 'spec_helper'

module NcsNavigator::Warehouse
  describe Contents do
    let(:enumerator) { Contents.new(spec_config, options) }
    let(:options) { { } }
    let(:yielded) { enumerator.to_a }

    def person_model
      spec_config.models_module.const_get(:Person)
    end

    def participant_model
      spec_config.models_module.const_get(:Participant)
    end

    def stub_model(model)
      model.stub!(:count).and_return(0)
    end

    before do
      spec_config.models_module.mdes_order.reject { |m|
        [person_model, participant_model].include?(m)
      }.each do |model|
        stub_model(model)
      end
    end

    describe '#each', :slow do
      def default_required_attributes(model)
        model.properties.select { |prop| prop.required? }.inject({}) { |h, prop|
          h[prop.name] = '-4'; h
        }
      end

      def create_instance(model, attributes)
        model.new(default_required_attributes(model).merge(attributes))
      end

      def create_person(id, attributes={})
        create_instance(person_model, { :person_id => id }.merge(attributes))
      end

      def yielded_for_model(name)
        yielded.select { |e| e.class.name =~ /#{name}\z/ }
      end

      before do
        records.each { |rec| rec.save or fail "Save of #{rec.inspect} failed." }
      end

      describe 'with exactly one actual record', :use_database do
        let(:records) {
          [
            create_person('XQ4')
          ]
        }

        it 'contains records for all models' do
          enumerator.to_a.size.should == 1
        end

        it 'contains the right records' do
          enumerator.collect { |e| e.person_id }.should == %w(XQ4)
        end
      end

      describe 'with actual data', :use_database do
        let(:records) {
          [
            create_person('XQ4', :first_name => 'Xavier'),
            create_person('QX9', :first_name => 'Quentin'),
            create_instance(participant_model, :p_id => 'P_QX4')
          ]
        }

        it 'contains records for all models' do
          enumerator.to_a.size.should == 3
        end

        it 'contains the right records' do
          enumerator.collect { |e| e.key.first }.sort.should == %w(P_QX4 QX9 XQ4)
        end

        describe 'and selected output' do
          let(:people_count) { yielded_for_model('Person').size }
          let(:p_count) { yielded_for_model('Participant').size }

          it 'includes all tables by default' do
            people_count.should == 2
            p_count.should == 1
          end

          it 'includes only the selected tables when requested' do
            options[:tables] = %w(participant)

            people_count.should == 0
            p_count.should == 1
          end

          it 'includes all the requested tables when explicitly requested' do
            options[:tables] = spec_config.models_module.mdes_order.collect(&:mdes_table_name)

            people_count.should == 2
            p_count.should == 1
          end
        end
      end

      describe 'with lots and lots of actual data', :use_database do
        let(:count) { 3134 }
        let(:records) { (0...count).collect { |n| create_person(n) } }
        let(:actual_ids) { enumerator.collect { |e| e.key.first } }

        before do
          options[:batch_size] = 150
        end

        it 'contains all the records' do
          actual_ids.size.should == count
        end

        it 'contains the right records' do
          actual_ids.collect(&:to_i).sort[2456].should == 2456
        end
      end
    end
  end
end
