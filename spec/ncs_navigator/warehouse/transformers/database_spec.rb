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

    describe '#initialize' do
      it 'sets up the repository'
    end

    describe 'transform' do
      it 'runs the entire transformation in a transaction'

      describe 'of .produce_records' do
        it 'uses the production name as a table name by default'
        it 'uses an explicit query if given'
        it 'wraps each row in a proxy'
        it 'saves multiple results per row'
        it 'saves one result per row'
        it 'records a validation failure'
        it 'attempts all transformations, even when some produce invalid results'
        it 'fails the transformation if there were any validation failures'
      end
    end
  end
end
