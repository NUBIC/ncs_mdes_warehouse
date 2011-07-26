require File.expand_path('../../../spec_helper', __FILE__)

require 'ncs_navigator/mdes'
require 'data_mapper'

module NcsNavigator::Warehouse
  module Spec
    ##
    # Target module for generated test models
    module ModeledTables
      def self.clear
        constants.each do |c|
          remove_const(c)
        end
      end
    end
  end

  describe TableModeler do
    let(:table) {
      NcsNavigator::Mdes::TransmissionTable.new('generational_tableau').tap do |t|
        t.variables = [
          NcsNavigator::Mdes::Variable.new('tableau_id').tap do |v|
            v.type = NcsNavigator::Mdes::VariableType.new('primaryKeyType').tap do |vt|
              vt.base_type = :string
            end
          end,
          NcsNavigator::Mdes::Variable.new(variable_name.to_s).tap do |v|
            v.type = NcsNavigator::Mdes::VariableType.new.tap do |vt|
              vt.base_type = :string
            end
          end,
          NcsNavigator::Mdes::Variable.new('transaction_type').tap do |v|
            v.type = NcsNavigator::Mdes::VariableType.new.tap do |vt|
              vt.base_type = :string
            end
          end
        ]
      end
    }
    let(:tables) { [table] }

    let(:variable) { table.variables[1] }
    let(:variable_name) { :age_span }

    let(:model_class) { Spec::ModeledTables::GenerationalTableau }
    let(:model_property) { model_class.properties[variable_name] }

    let(:path) { tmpdir('modeled_tables') }

    subject {
      TableModeler.new(tables, :module => Spec::ModeledTables, :path => path)
    }

    after do
      ::DataMapper::Model.descendants.clear
      Spec::ModeledTables.clear
    end

    it 'produces an appropriately named model' do
      subject.load!
      lambda { model_class }.should_not raise_error
    end

    it 'writes the model into the expected file' do
      subject.generate!
      expected_path = File.join(path, 'generational_tableau.rb')
      File.exist?(expected_path).should be_true
    end

    it 'produces a model with all the properties except for transaction_type' do
      subject.load!
      model_class.properties.collect(&:name).should == [:tableau_id, :age_span]
    end

    describe 'validation' do
      def actual(initial_values={})
        model_class.new({ :tableau_id => '1' }.merge(initial_values))
      end

      describe 'of code lists' do
        before do
          variable.type.code_list = NcsNavigator::Mdes::VariableType::CodeList.new
          variable.type.code_list << NcsNavigator::Mdes::VariableType::CodeListEntry.new('60336')
          variable.type.code_list << NcsNavigator::Mdes::VariableType::CodeListEntry.new('-4')

          subject.load!
        end

        it 'allows a matching value' do
          actual(variable_name => '60336').should be_valid
        end

        it 'blocks a non-matching value' do
          actual(variable_name => '1').should_not be_valid
        end

        it 'also sets a length range to suit' do
          model_class.properties[variable_name].options[:length].should == (2..5)
        end
      end

      describe 'length' do
        describe 'with minimum alone' do
          before do
            variable.type.min_length = 5

            subject.load!
          end

          it 'blocks a too-short value' do
            actual(variable_name => 'abcd').should_not be_valid
          end

          it 'allows the minimum' do
            actual(variable_name => 'abcde').should be_valid
          end

          it 'allows a very long value' do
            actual(variable_name => 'abcde' * 4000).should be_valid
          end
        end

        describe 'with maximum alone' do
          before do
            variable.type.max_length = 5

            subject.load!
          end

          it 'allows an empty value' do
            actual(variable_name => '').should be_valid
          end

          it 'allows a shorter value' do
            actual(variable_name => 'abc').should be_valid
          end

          it 'allows the maximum' do
            actual(variable_name => 'abcde').should be_valid
          end

          it 'blocks a too-long value' do
            actual(variable_name => 'abcdef').should_not be_valid
          end
        end

        describe 'with maximum and minimum' do
          before do
            variable.type.min_length = 9
            variable.type.max_length = 36

            subject.load!
          end

          it 'blocks a too-short value' do
            actual(variable_name => 'abcdabcd').should_not be_valid
          end

          it 'allows the minimum' do
            actual(variable_name => 'abcdedcba').should be_valid
          end

          it 'allows a value in the range' do
            actual(variable_name => 'xyz' * 9).should be_valid
          end

          it 'allows the maximum' do
            actual(variable_name => 'wxyz' * 9).should be_valid
          end

          it 'blocks a too-long value' do
            actual(variable_name => 'wxyz' * 10).should_not be_valid
          end
        end
      end

      describe 'when required' do
        before do
          variable.required = true
          subject.load!
        end

        it 'allows when set' do
          actual(variable_name => '15').should be_valid
        end

        it 'blocks when nil' do
          actual.should_not be_valid
        end
      end

      describe 'with a pattern' do
        before do
          variable.type.pattern = /foo/
          subject.load!
        end

        it 'accepts a value that matches' do
          actual(variable_name => 'foobar').should be_valid
        end

        it 'rejects a value that does not match' do
          actual(variable_name => 'quuxbar').should_not be_valid
        end
      end
    end

    describe 'type selection' do
      describe 'for xs:string' do
        before do
          variable.type.base_type = :string
        end

        it 'produces an NcsString when pattern-limited' do
          variable.type.pattern = /\d{4}/
          subject.load!

          model_property.should be_a DataMapper::NcsString
        end

        it 'produces an NcsString when from a code list' do
          variable.type.code_list = [NcsNavigator::Mdes::VariableType::CodeListEntry.new('foo')]
          subject.load!

          model_property.should be_a DataMapper::NcsString
        end

        it 'produces an NcsString when length-limited and short' do
          variable.type.max_length = 36
          subject.load!

          model_property.should be_a DataMapper::NcsString
        end

        it 'produces an NcsText when length-limited and long' do
          variable.type.max_length = 2000
          subject.load!

          model_property.should be_a DataMapper::NcsText
        end

        it 'produces an NcsText when unlimited' do
          subject.load!

          model_property.should be_a DataMapper::NcsText
        end
      end

      describe 'for xs:int' do
        before do
          variable.type.base_type = :int
          subject.load!
        end

        it 'produces an NcsInteger' do
          model_property.should be_a DataMapper::NcsInteger
        end
      end

      describe 'for xs:decimal' do
        before do
          variable.type.base_type = :decimal
          subject.load!
        end

        it 'produces an NcsDecimal' do
          model_property.should be_a DataMapper::NcsDecimal
        end

        it 'sets the precision to 128 since DataMapper forces you to set it' do
          model_property.precision.should == 128
        end

        it 'sets the scale to 64 since DataMapper forces to to set it' do
          model_property.scale.should == 64
        end
      end

      it 'preserves the PII value' do
        variable.pii = :possible
        subject.load!

        model_property.pii.should == :possible
      end
    end

    describe 'key detection' do
      it 'uses a property typed primaryKeyType as the PK' do
        subject.load!
        model_class.properties[:tableau_id].options[:key].should be_true
      end

      it 'fails to generate if no key can be found for a table' do
        table.variables.delete(table.variables.first)
        lambda { subject.generate! }.should raise_error(
          'Could not determine key to use for generational_tableau table')
      end

      it 'has special treatment for the study_center table' do
        tables[0] =
          NcsNavigator::Mdes::TransmissionTable.new('study_center').tap do |t|
            t.variables = [
              NcsNavigator::Mdes::Variable.new('sc_id').tap do |v|
                v.type = NcsNavigator::Mdes::VariableType.new.tap do |vt|
                  vt.base_type = :string
                end
                v.required = true
              end,
              NcsNavigator::Mdes::Variable.new('sc_name').tap do |v|
                v.type = NcsNavigator::Mdes::VariableType.new.tap do |vt|
                  vt.base_type = :string
                end
              end,
              NcsNavigator::Mdes::Variable.new('comments').tap do |v|
                v.pii = :possible
                v.type = NcsNavigator::Mdes::VariableType.new.tap do |vt|
                  vt.base_type = :string
                end
              end
            ]
          end

        subject.load!

        NcsNavigator::Warehouse::Spec::ModeledTables::
          StudyCenter.properties[:sc_id].options[:key].should be_true
      end

      it 'has special treatment for the psu table' do
        tables[0] =
          NcsNavigator::Mdes::TransmissionTable.new('psu').tap do |t|
            t.variables = [
              NcsNavigator::Mdes::Variable.new('sc_id').tap do |v|
                v.type = NcsNavigator::Mdes::VariableType.new.tap do |vt|
                  vt.base_type = :string
                end
                v.required = true
              end,
              NcsNavigator::Mdes::Variable.new('psu_id').tap do |v|
                v.type = NcsNavigator::Mdes::VariableType.new.tap do |vt|
                  vt.base_type = :string
                end
                v.required = true
              end,
              NcsNavigator::Mdes::Variable.new('recruit_type').tap do |v|
                v.type = NcsNavigator::Mdes::VariableType.new.tap do |vt|
                  vt.base_type = :string
                end
              end
            ]
          end

        subject.load!

        NcsNavigator::Warehouse::Spec::ModeledTables::
          Psu.properties[:psu_id].options[:key].should be_true
      end
    end

    describe 'with the real MDES', :slow do
      before do
        tables.clear
        tables.concat(NcsNavigator::Mdes('2.0').transmission_tables)
      end

      it 'does not raise any errors' do
        lambda { subject.model! }.should_not raise_error
      end
    end
  end
end
