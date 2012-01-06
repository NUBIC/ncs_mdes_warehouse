require File.expand_path('../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse
  describe DatabaseInitializer do
    describe '#replace_schema', :slow, :use_mdes do
      subject { DatabaseInitializer.new(spec_config) }

      before do
        subject.set_up_repository(:both)
      end

      def table_names(schema)
        ::DataMapper.repository("mdes_warehouse_#{schema}").adapter.select(
          "SELECT table_name FROM information_schema.tables WHERE table_schema='public'")
      end

      it 'does not touch the default repository' do
        subject.drop_all(:reporting) # just to make sure
        subject.replace_schema
        table_names(:reporting).should == []
      end

      it 'creates all the MDES model tables' do
        subject.replace_schema
        (spec_config.models_module.mdes_order.collect(&:mdes_table_name) - table_names(:working)).
          should == []
      end

      it 'creates the ancillary warehouse information tables' do
        subject.replace_schema
        table_names(:working).select { |n| n =~ /^wh_/ }.size.should == 2
      end

      describe 'with foreign keys' do
        let(:foreign_keys) {
          ::DataMapper.repository("mdes_warehouse_working").adapter.select(
            %q{
               SELECT constraint_name, is_deferrable
               FROM information_schema.table_constraints
               WHERE constraint_schema='public'
                 AND constraint_type='FOREIGN KEY'
            })
        }

        before do
          pending '#1639'
          subject.replace_schema
        end

        it 'creates them' do
          foreign_keys.should_not == []
        end

        it 'flags them as deferrable' do
          foreign_keys.collect(&:is_deferrable).uniq.should == %w(YES)
        end
      end
    end
  end
end
