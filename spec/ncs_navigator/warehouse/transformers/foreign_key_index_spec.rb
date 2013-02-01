require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe ForeignKeyIndex, :modifies_warehouse_state do
    class Addr
      include ::DataMapper::Resource

      property :psu_id, String
      property :a_id, Integer, :key => true

      belongs_to :old_one, self, :child_key => [ :old_one_id ]
      belongs_to :frob, 'NcsNavigator::Warehouse::Transformers::Frob', :child_key => [ :frob_id ]
    end

    class Frob
      include ::DataMapper::Resource

      property :psu_id, String
      property :f_id, Integer, :key => true
    end

    class Subcircle1
      include ::DataMapper::Resource

      property :id, Integer, :key => true
      belongs_to :subcircle2, 'NcsNavigator::Warehouse::Transformers::Subcircle2',
        :required => false, :child_key => [ :subcircle2_id ]

      belongs_to :addr, 'NcsNavigator::Warehouse::Transformers::Addr', :child_key => [ :addr_id ]
    end

    class Subcircle2
      include ::DataMapper::Resource

      property :id, Integer, :key => true
      belongs_to :subcircle3, 'NcsNavigator::Warehouse::Transformers::Subcircle3',
        :required => false, :child_key => [ :subcircle3_id ]
    end

    class Subcircle3
      include ::DataMapper::Resource

      property :id, Integer, :key => true
      belongs_to :subcircle1, 'NcsNavigator::Warehouse::Transformers::Subcircle1',
        :required => false, :child_key => [ :subcircle1_id ]
    end

    before(:each) do
      DataMapper.finalize
    end

    let(:fk_index) { ForeignKeyIndex.new(:existing_key_provider => key_provider) }
    let(:key_provider) { ForeignKeyIndex::StaticKeyProvider.new(Addr.to_s => [120, 180], Frob.to_s => [80]) }
    let(:transform_status) { NcsNavigator::Warehouse::TransformStatus.memory_only('test') }
    let(:errors) { transform_status.transform_errors }

    def verify_and_record_if_appropriate(rec, index=fk_index)
      if v = index.verify_or_defer(rec)
        index.record(rec)
      end
      v
    end

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
        fk_index.start_transform(transform_status)
        verify_and_record_if_appropriate(Frob.new(:f_id => 8))
        verify_and_record_if_appropriate(Frob.new(:f_id => 16))
      end

      it 'does not report for a key which is satisfied when it is first recorded' do
        verify_and_record_if_appropriate(Addr.new(:frob_id => 8, :a_id => 1))
        fk_index.end_transform

        errors.should == []
      end

      it 'does not report for a key which is not initially satisfied but is later' do
        verify_and_record_if_appropriate(Addr.new(:frob_id => 4, :a_id => 1))
        verify_and_record_if_appropriate(Frob.new(:f_id => 4))
        fk_index.end_transform

        errors.should == []
      end

      it 'does not report for a key which is provided by the external key provider' do
        verify_and_record_if_appropriate(Addr.new(:a_id => 8, :old_one_id => 120))
        fk_index.end_transform

        errors.should == []
      end

      it 'does not report for a key which is provided by the external key provider when the associated model class has not previously been referenced' do
        another_index = ForeignKeyIndex.new(:existing_key_provider => key_provider)
        another_index.start_transform(transform_status)

        verify_and_record_if_appropriate(Addr.new(:a_id => 8, :frob_id => 80), another_index)
        another_index.end_transform

        errors.should == []
      end

      describe 'when a key is never satisfied' do
        before do
          verify_and_record_if_appropriate(Addr.new(:frob_id => 4, :a_id => 1))
          fk_index.end_transform
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
            'Unsatisfied foreign key referencing NcsNavigator::Warehouse::Transformers::Frob.'
        end

        it 'includes the referencing attribute name' do
          errors.first.attribute_name.should == 'frob_id'
        end

        it 'includes the unsatisfied value' do
          errors.first.attribute_value.should == '4'
        end

        it 'only reports the error for the transform in which it occurs' do
          fk_index.start_transform(NcsNavigator::Warehouse::TransformStatus.memory_only('test2'))
          fk_index.end_transform

          errors.size.should == 1
        end
      end

      it 'reports multiple failed references for a single record' do
        verify_and_record_if_appropriate(Addr.new(:a_id => 1, :frob_id => 2, :old_one_id => 3))
        fk_index.end_transform

        errors.collect { |e| [e.attribute_name, e.attribute_value] }.sort.should ==
          [['frob_id', '2'], ['old_one_id', '3']]
      end
    end

    describe 'complex deferred foreign key resolution' do
      # The full set of records produces a consistent graph like this:
      #  frob1 <- addr1 <- circle11 -> circle21 -> circle31
      #                       ^                       |
      #                       \_______________________|
      # The various test contexts simulate difficulties by presenting the
      # records in a different order or by removing some of them.
      let(:frob1) { Frob.new(:f_id => 1) }
      let(:addr1) { Addr.new(:a_id => 1, :frob_id => 1)}
      let(:circle11) { Subcircle1.new(:id => 1, :addr_id => 1, :subcircle2_id => 1)}
      let(:circle21) { Subcircle2.new(:id => 1, :subcircle3_id => 1)}
      let(:circle31) { Subcircle3.new(:id => 1, :subcircle1_id => 1)}

      before do
        fk_index.start_transform(transform_status)
      end

      def record_idents(records)
        records.collect { |rec| [rec.class.to_s.split(':').last, rec.key.first].join('-') }
      end

      describe 'nested out-of-order records which are eventually resolvable' do
        let!(:record_and_verify_results) {
          circle21.subcircle3_id = nil

          [circle21, circle11, addr1, frob1].each_with_object({}) do |rec, results|
            results[rec] = verify_and_record_if_appropriate(rec)
          end
        }

        it 'defers records with unresolvable FKs' do
          record_and_verify_results[addr1].should be_false
        end

        it 'defers records that refer to records with unresolvable FKs' do
          record_and_verify_results[circle11].should be_false
        end

        it 'accepts records which are initially resolved' do
          [circle21, frob1].collect { |rec| record_and_verify_results[rec] }.should == [true, true]
        end

        describe 'after all records are visited' do
          let!(:deferred_records) { fk_index.end_transform }

          it 'reports no errors' do
            errors.should == []
          end

          it 'returns the records which may now be saved' do
            record_idents(deferred_records).sort.should == %w(Addr-1 Subcircle1-1)
          end
        end
      end

      describe 'nested out-of-order records which are not all eventually resolvable' do
        let!(:record_and_verify_results) {
          [circle21, circle11, addr1, frob1].each_with_object({}) do |rec, results|
            results[rec] = verify_and_record_if_appropriate(rec)
          end
        }

        it 'defers records with unresolvable FKs' do
          [circle21, addr1].collect { |rec| record_and_verify_results[rec] }.should == [false, false]
        end

        it 'defers records that refer to records with unresolvable FKs' do
          record_and_verify_results[circle11].should be_false
        end

        it 'accepts records which are initially resolved' do
          record_and_verify_results[frob1].should be_true
        end

        describe 'after all records are visited' do
          let!(:deferred_records) { fk_index.end_transform }

          it 'returns the records which may now be saved' do
            record_idents(deferred_records).should == %w(Addr-1)
          end

          it 'reports errors for the remaining unresolvable items' do
            errors.collect(&:model_class).sort.should == [Subcircle1.to_s, Subcircle2.to_s]
          end

          describe 'the error for a record which has an unresolvable FK' do
            let(:the_error) { errors.find { |e| e.model_class == Subcircle2.to_s } }

            it 'reports the error' do
              the_error.message.should == 'Unsatisfied foreign key referencing NcsNavigator::Warehouse::Transformers::Subcircle3.'
            end

            it 'includes the attribute name' do
              the_error.attribute_name.should == 'subcircle3_id'
            end

            it 'includes the attribute value' do
              the_error.attribute_value.should == '1'
            end
          end

          describe 'the error for a record which refers to a record that has an unresolvable FK' do
            let(:the_error) { errors.find { |e| e.model_class == Subcircle1.to_s } }

            it 'reports the error' do
              the_error.message.should == 'Associated NcsNavigator::Warehouse::Transformers::Subcircle2 record contains one or more unsatisfed foreign keys or refers to other records that do.'
            end

            it 'includes the attribute name' do
              the_error.attribute_name.should == 'subcircle2_id'
            end

            it 'includes the attribute value' do
              the_error.attribute_value.should == '1'
            end
          end
        end
      end

      describe 'circular records which are eventually resolvable' do
        let!(:record_and_verify_results) {
          [frob1, circle21, circle11, addr1, circle31].each_with_object({}) do |rec, results|
            results[rec] = verify_and_record_if_appropriate(rec)
          end
        }

        it 'defers all the records in the circle' do
          [circle11, circle21, circle31].collect { |rec| record_and_verify_results[rec] }.should == [false] * 3
        end

        it 'accepts records which are initially resolved' do
          [frob1, addr1].collect { |rec| record_and_verify_results[rec] }.should == [true] * 2
        end

        describe 'after all records are visited' do
          let!(:deferred_records) { fk_index.end_transform }

          it 'reports no errors' do
            errors.should == []
          end

          it 'returns all the records in the circle' do
            record_idents(deferred_records).sort.should == %w(Subcircle1-1 Subcircle2-1 Subcircle3-1)
          end
        end
      end

      describe 'circular records which are not eventually resolvable' do
        let!(:record_and_verify_results) {
          [circle21, circle11, circle31].each_with_object({}) do |rec, results|
            results[rec] = verify_and_record_if_appropriate(rec)
          end
        }

        it 'defers all the records in the circle' do
          [circle11, circle21, circle31].collect { |rec| record_and_verify_results[rec] }.should == [false] * 3
        end

        describe 'after all records are visited' do
          let!(:deferred_records) { fk_index.end_transform }

          it 'reports an error for each record in the circle, including one for the bad external ref' do
            errors.collect(&:model_class).sort.should == [Subcircle1.to_s, Subcircle1.to_s, Subcircle2.to_s, Subcircle3.to_s]
          end

          describe 'the error for the element with the unresolvable FK' do
            let(:the_error) { errors.find { |e| e.model_class == Subcircle1.to_s && e.attribute_name == 'addr_id' } }

            it 'reports the error' do
              the_error.message.should == 'Unsatisfied foreign key referencing NcsNavigator::Warehouse::Transformers::Addr.'
            end

            it 'includes the attribute name' do
              the_error.attribute_name.should == 'addr_id'
            end

            it 'includes the attribute value' do
              the_error.attribute_value.should == '1'
            end
          end

          describe 'an error for an element in the circle' do
            let(:the_error) { errors.find { |e| e.model_class == Subcircle3.to_s } }

            it 'reports the error' do
              the_error.message.should == 'Associated NcsNavigator::Warehouse::Transformers::Subcircle1 record contains one or more unsatisfed foreign keys or refers to other records that do.'
            end

            it 'includes the attribute name' do
              the_error.attribute_name.should == 'subcircle1_id'
            end

            it 'includes the attribute value' do
              the_error.attribute_value.should == '1'
            end
          end

          it 'returns nothing' do
            deferred_records.should == []
          end
        end
      end
    end
  end
end
