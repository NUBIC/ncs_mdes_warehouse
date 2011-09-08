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
              v.required = false
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

    let(:path) { tmpdir }

    let(:options) {
      { :module => Spec::ModeledTables, :path => path }
    }

    subject {
      TableModeler.new(tables, options)
    }

    def reset_models
      ::DataMapper::Model.descendants.clear
      Spec::ModeledTables.clear
    end

    after do
      reset_models
    end

    it 'produces an appropriately named model' do
      subject.load!
      lambda { model_class }.should_not raise_error
    end

    it 'writes the model into the expected file' do
      subject.generate!
      expected_path =
        File.join(path, 'ncs_navigator/warehouse/spec/modeled_tables', 'generational_tableau.rb')
      File.exist?(expected_path).should be_true
    end

    it 'produces a model with all the properties except for transaction_type' do
      subject.load!
      model_class.properties.collect(&:name).should == [:tableau_id, :age_span]
    end

    it 'produces a model with the mdes_order set' do
      subject.load!
      model_class.mdes_order.should == [:tableau_id, :age_span]
    end

    it 'preserves non-reversible table names' do
      table.instance_eval { @name = 'generational_tableau_1' }
      subject.load!
      Spec::ModeledTables::GenerationalTableau1.
        storage_names[:default].should == 'generational_tableau_1'
    end

    [:default, :mdes_warehouse_working, :mdes_warehouse_reporting].each do |repo|
      it "sets the storage name for the #{repo} repo" do
        subject.load!
        model_class.storage_names[repo].should == 'generational_tableau'
      end
    end

    describe 'the main entry file' do
      before do
        subject.generate!
        expected_path = File.join(path, 'ncs_navigator/warehouse/spec/modeled_tables.rb')
        @contents = File.read(expected_path).strip
      end

      it 'requires all the models' do
        @contents.should =~
          %r{require 'ncs_navigator/warehouse/spec/modeled_tables/generational_tableau'$}
      end

      it 'sets the model order' do
        @contents.should =~
          %r{mdes_order GenerationalTableau}
      end

      it 'defines the module' do
        expected = (<<-MOD).strip
module NcsNavigator
  module Warehouse
    module Spec
      module ModeledTables
        extend NcsNavigator::Warehouse::Models::MdesModelCollection
      end
    end
  end
end
        MOD
@contents.should include(expected)
      end
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

      it 'preserves the omittableness' do
        variable.omittable = true
        subject.load!

        model_property.omittable.should be_true
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

    describe 'foreign key creation' do
      let(:parent_table) do
        NcsNavigator::Mdes::TransmissionTable.new('tree').tap do |t|
          t.variables = [
            NcsNavigator::Mdes::Variable.new('tree_id').tap do |v|
              v.type = NcsNavigator::Mdes::VariableType.new('primaryKeyType').tap do |vt|
                vt.base_type = :string
              end
              v.required = true
            end
          ]
        end
      end

      before do
        table.variables << NcsNavigator::Mdes::Variable.new('some_tree_id').tap do |v|
          v.table_reference = parent_table
          v.type = NcsNavigator::Mdes::VariableType.new('foreignKeyRequiredType').tap do |vt|
            vt.base_type = :string
            v.required = false
          end
        end
        tables << parent_table

        subject.load!
      end

      describe 'from child to parent' do
        let(:relationship) { model_class.relationships.first }

        it 'has the correct child key' do
          relationship.child_key.collect(&:name).should == [:some_tree_id]
        end

        it 'has the correct parent key' do
          relationship.parent_key.collect(&:name).should == [:tree_id]
        end

        it 'has the expected accessor name' do
          # to_s is so this will run on both 1.8.7 and 1.9.2
          model_class.instance_methods.collect(&:to_s).should include('some_tree')
        end

        it 'has the expected parent model name' do
          relationship.parent_model_name.should ==
            'NcsNavigator::Warehouse::Spec::ModeledTables::Tree'
        end

        it 'is not mandatory if the FK is not mandatory' do
          instance = model_class.new
          instance.tableau_id = '7'
          instance.some_tree = nil

          instance.should be_valid
        end

        it 'is mandatory if the FK is mandatory' do
          table.variables.last.required = true
          reset_models
          subject.load!

          instance = model_class.new
          instance.tableau_id = '7'
          instance.some_tree = nil

          instance.should_not be_valid
        end
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

    describe '#initialize' do
      describe 'of path' do
        it 'is mandatory' do
          options.delete(:path)
          lambda { subject }.should raise_error(/path/)
        end

        it 'appends a patherized version of the module name' do
          options.merge!(:path => '.', :module => 'Foo::Ncs::Things')
          subject.path.should == './foo/ncs/things'
        end
      end

      describe 'of module_name' do
        it 'is mandatory' do
          options.delete :module
          lambda { subject }.should raise_error(/module/)
        end
      end
    end

    describe '.for_version', :slow do
      it 'derives the module name from the version' do
        TableModeler.for_version('1.2', :path => '.').module_name.
          should == 'NcsNavigator::Warehouse::Models::OnePointTwo'
      end

      it 'prepends the specified path if any' do
        TableModeler.for_version('1.2', :path => 'quux/zap/').path.
          should == 'quux/zap/ncs_navigator/warehouse/models/one_point_two'
      end

      it 'takes the tables from the appropriate ncs_mdes Specification' do
        TableModeler.for_version('2.0', :path => '.').tables.collect(&:name).
          should == NcsNavigator::Mdes('2.0').transmission_tables.collect(&:name)
      end
    end
  end
end
