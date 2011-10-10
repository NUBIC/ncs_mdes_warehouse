require File.expand_path('../../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse::Transformers
  describe Database do
    def sample_class(&contents)
      Class.new do
        include Database

        class_eval(&contents) if contents
      end
    end

    describe '#repository_name' do
      it 'defaults to the class name, underscored' do
        cls = (FooBaz = sample_class)
        cls.new.repository_name.should == :foo_baz
      end

      it 'can be overridden at the class level' do
        cls = sample_class do
          repository :data_goes_here
        end

        cls.new.repository_name.should == :data_goes_here
      end

      it 'can be overridden at the instance level with the :repository key' do
        sample_class.new(:repository => :bazQuux).repository_name.should == :bazQuux
      end

      it 'can be overridden at the instance level with the :repository_name key' do
        sample_class.new(:repository_name => :bazQuux).repository_name.should == :bazQuux
      end
    end

    describe '#connection_parameters' do
      describe 'from bcdatabase' do
        it 'defaults the group from the environment'

        let(:cls) {
          sample_class do
            bcdatabase :name => 'ncs_staff_portal'
          end
        }

        it 'uses the values set in the class' do
          cls.new.connection_parameters['database'].should == 'ncs_sp'
        end

        it 'can be overridden at the instance level' do
          cls.new(:bcdatabase => { :name => 'ncs_staff_portal_test' }).
            connection_parameters['database'].should == 'ncs_sp_test'
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

      let(:enum) do
        sample_class do
          repository :people_pro

          bcdatabase :group => 'test_sqlite', :name => 'people_pro'
        end.new
      end

      it 'sets up the repository' do
        lambda {
          enum.repository.adapter.options['path'].should == 'people_pro.sqlite3'
        }.should_not raise_error
      end
    end

    describe '#each' do
      include_context 'people_pro'

      describe 'of .produce_records' do
        let(:enumerator_def) do
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

        let(:enumerator) { enumerator_def.new }

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
      end
    end
  end
end
