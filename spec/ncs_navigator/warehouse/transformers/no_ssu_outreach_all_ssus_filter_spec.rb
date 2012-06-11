require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe NoSsuOutreachAllSsusFilter, :use_mdes do
    describe '#initialize' do
      it 'defaults the SSU list to the configuration list' do
        NoSsuOutreachAllSsusFilter.new(spec_config).ssu_ids.sort.should == %w(204 24 42)
      end

      it 'accepts an override SSU ID list (mainly for testing)' do
        NoSsuOutreachAllSsusFilter.new(spec_config, :ssu_ids => %w(1 2 3)).ssu_ids.
          should == %w(1 2 3)
      end
    end

    let(:filter) {
      NoSsuOutreachAllSsusFilter.new(spec_config, :ssu_ids => all_ssus)
    }

    let(:all_ssus) {
      %w(A X Y N)
    }

    describe 'on an outreach event' do
      describe 'that has an SSU ID' do
        let(:outreach_event) { mdes_model(:outreach).new(:ssu_id => 'foo') }
        let(:result) { filter.call([outreach_event]) }

        it 'returns only the input OE' do
          result.should == [outreach_event]
        end

        it 'does not change the SSU ID' do
          result.first.ssu_id.should == 'foo'
        end
      end

      describe 'that do not have an SSU ID' do
        let(:outreach_event) {
          mdes_model(:outreach).new(
            :outreach_event_id => '1701',
            :outreach_event_date => '2010-06-14',
            :outreach_type => '11',
            :incident_id => '0'
          )
        }
        let(:result) { filter.call([outreach_event]) }

        it 'replicates the record once per SSU ID' do
          result.size.should == all_ssus.size
        end

        it 'omits the original record' do
          result.collect(&:outreach_event_id).should_not include('1701')
        end

        describe 'each replica record' do
          it 'is an outreach event record' do
            result.collect(&:class).uniq.should == [mdes_model(:outreach)]
          end

          it 'has a unique ID' do
            result.collect(&:outreach_event_id).uniq.
              should == %w(1701-A 1701-X 1701-Y 1701-N)
          end

          it 'has the appropriate SSU ID' do
            result.collect(&:ssu_id).should == all_ssus
          end

          it 'has all the properties of the source record' do
            result[2].outreach_event_date.should == '2010-06-14'
            result[3].incident_id.should == '0'
            result[1].outreach_type.should == '11'
          end

          # This test added because .dup does not work on DM model
          # instances. This test takes advantage of one of the
          # symptoms to ensure that the implementation is creating
          # properly persistable replicas.
          it 'will persist all attributes' do
            result[2].dirty_attributes.keys.collect(&:name).should include(:outreach_type)
          end
        end
      end
    end

    %w(outreach_race outreach_staff outreach_eval outreach_target outreach_lang2).each do |assoc|
      describe "on an #{assoc} record" do
        let(:outreach_event) {
          mdes_model(:outreach).new(:outreach_event_id => '402')
        }

        let(:associated_model) { mdes_model(assoc) }
        let(:associated_model_key) { associated_model.key.first.name }
        let(:an_associated_model_property) {
          associated_model.properties.to_a.reverse.
            find { |prop| prop.name != :outreach_event_id }.name
        }

        let(:associated_record) {
          associated_model.new(
            associated_model_key => '11',
            an_associated_model_property => 'foo',
            :outreach_event_id => outreach_event.outreach_event_id
          )
        }

        let(:result) { filter.call([outreach_event, associated_record]) }
        let(:associated_model_results) {
          result.select { |r| r.class.mdes_table_name != 'outreach' }
        }

        describe 'when the associated outreach event did not have an SSU' do
          it 'replicates the record for each outreach event replica' do
            associated_model_results.size.should == all_ssus.size
          end

          it 'omits the original record' do
            associated_model_results.collect { |r| r.send(associated_model_key) }.
              should_not include('11')
          end

          describe 'each replica record' do
            it 'is an instance of the associated class' do
              associated_model_results.collect(&:class).uniq.should == [associated_model]
            end

            it 'has a unique ID' do
              associated_model_results.collect { |r| r.send(associated_model_key) }.
                should == %w(11-A 11-X 11-Y 11-N)
            end

            it 'has all the properties of the source record' do
              associated_model_results.collect { |r| r.send(an_associated_model_property) }.uniq.
                should == ['foo']
            end

            # This test added because .dup does not work on DM model
            # instances. This test takes advantage of one of the
            # symptoms to ensure that the implementation is creating
            # properly persistable replicas.
            it 'will persist all attributes' do
              associated_model_results[1].dirty_attributes.keys.collect(&:name).
                should include(an_associated_model_property)
            end
          end
        end

        describe 'when the associated outreach event had an SSU' do
          before do
            outreach_event.ssu_id = 'foo'
          end

          it 'returns only the input records' do
            associated_model_results.should == [associated_record]
          end

          it 'does not change the record OE ID' do
            associated_record.outreach_event_id.should == '402'
          end
        end
      end
    end
  end
end
