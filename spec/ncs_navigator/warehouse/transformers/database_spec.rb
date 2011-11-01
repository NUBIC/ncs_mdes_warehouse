require File.expand_path('../../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse::Transformers
  describe Database do
    def sample_class(&contents)
      Class.new do
        include Database

        class_eval(&contents) if contents
      end
    end

    let(:configuration) {
      NcsNavigator::Warehouse::Configuration.new.tap do |c|
        c.log_file = tmpdir + 'test.log'
        c.output_level = :quiet
      end
    }
    let(:options) { {} }
    let(:instance) { cls.new(configuration, options) }
    let(:cls) { @cls }

    describe '#repository_name' do
      it 'defaults to the class name, underscored' do
        @cls = (FooBaz = sample_class)
        instance.repository_name.should == :foo_baz
      end

      it 'can be overridden at the class level' do
        @cls = sample_class do
          repository :data_goes_here
        end

        instance.repository_name.should == :data_goes_here
      end

      it 'can be overridden at the instance level with the :repository key' do
        @cls = sample_class
        options[:repository] = :bazQuux
        instance.repository_name.should == :bazQuux
      end

      it 'can be overridden at the instance level with the :repository_name key' do
        @cls = sample_class
        options[:repository_name] = :bazQuux
        instance.repository_name.should == :bazQuux
      end
    end

    describe '#connection_parameters' do
      describe 'from bcdatabase', :modifies_warehouse_state do
        let(:cls) {
          sample_class do
            bcdatabase :name => 'ncs_staff_portal'
          end
        }

        it 'uses the values set in the class' do
          instance.connection_parameters['database'].should == 'ncs_sp'
        end

        it 'can be overridden at the instance level' do
          options[:bcdatabase] = { :name => 'ncs_staff_portal_test' }
          instance.connection_parameters['database'].should == 'ncs_sp_test'
        end

        it 'defaults the group from the environment' do
          NcsNavigator::Warehouse.env = 'staging'
          instance.bcdatabase[:group].should == :ncsdb_staging
        end
      end
    end

    shared_context 'people_pro' do
      let(:database_file) { 'people_pro.sqlite3' }

      after(:all) do
        FileUtils.rm_rf database_file
      end
    end

    describe '#repository' do
      include_context 'people_pro'

      let(:cls) do
        sample_class do
          repository :people_pro

          bcdatabase :group => 'test_sqlite', :name => 'people_pro'
        end
      end

      it 'sets up the repository' do
        lambda {
          instance.repository.adapter.options['path'].should == 'people_pro.sqlite3'
        }.should_not raise_error
      end
    end

    describe '#each' do
      include_context 'people_pro'

      describe 'of .produce_records' do
        let(:cls) do
          sample_class do
            bcdatabase :group => 'test_sqlite', :name => 'people_pro'
            repository :people_pro

            produce_records :people do |row|
              row.id
            end

            produce_records :other_persons, :query => 'SELECT * FROM more_people' do |row|
              [
                row.id + 'X',
                row.id + 'Y'
              ]
            end
          end
        end

        let(:enumerator_def) { cls }
        let(:enumerator) { instance }

        before do
          execute_sql(
            "CREATE TABLE people (id VARCHAR(24), name VARCHAR(255))",
            "CREATE TABLE more_people (id VARCHAR(24), name VARCHAR(255))"
          )
        end

        after do
          execute_sql("DROP TABLE people", "DROP TABLE more_people")
        end

        def execute_sql(*stmts)
          stmts.each { |stmt| enumerator.repository.adapter.execute stmt }
        end

        it 'uses the production name as a table name by default' do
          enumerator_def.record_producers[0].query.should == 'SELECT * FROM people'
        end

        it 'uses an explicit query if given' do
          enumerator_def.record_producers[1].query.should == 'SELECT * FROM more_people'
        end

        it 'can return multiple results per row' do
          execute_sql(
            "INSERT INTO people (id) VALUES ('A')",
            "INSERT INTO more_people (id) VALUES ('S')"
          )

          enumerator.to_a.should == %w(A SX SY)
        end

        it 'can execute just one producer' do
          execute_sql(
            "INSERT INTO people (id) VALUES ('A')",
            "INSERT INTO more_people (id) VALUES ('S')"
          )

          acc = []
          enumerator.each(:people) do |r|
            acc << r
          end

          acc.should == %w(A)
        end

        it 'can execute just one producer by calling :to_a' do
          execute_sql(
            "INSERT INTO people (id) VALUES ('B')",
            "INSERT INTO more_people (id) VALUES ('Q')"
          )

          enumerator.to_a(:people).should == %w(B)
        end
      end
    end

    describe '.create_transformer' do
      let(:enumerator_def) { sample_class }
      subject { enumerator_def.create_transformer(configuration) }

      it 'creates an EnumTransformer' do
        subject.should be_an EnumTransformer
      end

      it 'creates an enumerator from the source class' do
        subject.enum.should be_an enumerator_def
      end

      describe 'with options' do
        subject { enumerator_def.create_transformer(configuration, :repository => :alpha) }

        it 'passes the options to the enumerable constructor' do
          subject.enum.repository_name.should == :alpha
        end
      end
    end

    describe Database::DSL do
      describe '#unused_columns' do
        it 'defaults to :ignore' do
          sample_class.unused_columns.should == :ignore
        end

        it 'can be set' do
          sample_class { unused_columns :fail }.unused_columns.should == :fail
        end
      end

      describe '#model_row' do
        # DataMapper models can't be anonymous
        module Database::DSL::TestModels
          class Address
            include ::DataMapper::Resource

            property   :address_id, String, :key => true
            property   :street, NcsNavigator::Warehouse::DataMapper::NcsString
            property   :address_type,
                       NcsNavigator::Warehouse::DataMapper::NcsString,
                       { :required => true, :length => 1..2, :set => ["1", "2", "3", "4", "5", "-5", "-6", "-4"] }
            property   :address_type_oth,
                       NcsNavigator::Warehouse::DataMapper::NcsString,
                       { :pii => :possible, :length => 0..255 }
          end

          Address.finalize
        end

        let(:address_model) { Database::DSL::TestModels::Address }

        let(:options) { {} }
        let(:cls) { sample_class }

        def make_row(contents)
          Struct.new(*contents.keys).new.tap do |r|
            contents.each_pair do |c, v|
              r.send("#{c}=", v)
            end
          end
        end

        def model_row(row)
          cls.model_row(address_model, make_row(row), options)
        end

        it 'maps a column to the property with the same name' do
          model_row(:street => '123 Anymain Dr.').street.should == '123 Anymain Dr.'
        end

        it 'maps a column named {X}_code to a property named {X}' do
          model_row(:address_type_code => '5').address_type.should == '5'
        end

        it 'maps a column named {X}_code to a property named {X}_id' do
          model_row(:address_code => '-7').address_id.should == '-7'
        end

        it 'maps a column named {X}_other to a property named {X}_oth' do
          model_row(:address_type_other => 'Elephant graveyard').address_type_oth.
            should == 'Elephant graveyard'
        end

        describe 'and unused columns' do
          it 'fails with unused columns if requested' do
            options[:unused] = :fail
            begin
              model_row(:address_type => '-5', :address_length => '6')
              fail "Exception not thrown"
            rescue Database::UnusedColumnsForModelError => e
              e.unused.should == [:address_length]
            end
          end

          it 'does not fail if the unused column is explicitly ignored' do
            options[:unused] = :fail
            options[:used] = %w(address_length)
            lambda { model_row(:address_type => '-5', :address_length => '6') }.
              should_not raise_error
          end

          describe 'when #unused_columns is set to :fail' do
            let(:cls) {
              sample_class do
                unused_columns :fail
              end
            }

            it 'fails appropriately' do
              begin
                model_row(:address_type => '-5', :address_length => '6')
                fail "Exception not thrown"
              rescue Database::UnusedColumnsForModelError => e
                e.unused.should == [:address_length]
              end
            end

            it 'does not fail if the global setting is overridden' do
              options[:unused] = :ignore
              lambda { model_row(:address_type => '-5', :address_length => '6') }.
                should_not raise_error
            end
          end
        end

        describe 'with a prefix' do
          before do
            options[:prefix] = 'address_'
          end

          it 'maps a column to {prefix}_{property_name}' do
            model_row(:type => '-4').address_type.should == '-4'
          end

          it 'still maps a column to {property_name} if there is no prefixed version' do
            model_row(:street => '123 Anymain Dr.').street.should == '123 Anymain Dr.'
          end

          it 'maps a column named {X}_code to {prefix}{X}' do
            model_row(:type_code => '1').address_type.should == '1'
          end
        end

        describe 'with explicit mappings' do
          before do
            options[:explicit] = {
              :street => '456 Anywhere St.'
            }
          end

          it 'prefers the explicit mapping to a column' do
            model_row(:street => '123 Anymain Dr.').street.should == '456 Anywhere St.'
          end

          it 'reports the column as unused' do
            options[:unused] = :fail
            begin
              model_row(:street => '123 Anymain Dr.').street.should == '456 Anywhere St.'
              fail "Exception not thrown"
            rescue Database::UnusedColumnsForModelError => e
              e.unused.should include(:street)
            end
          end
        end
      end
    end
  end
end
