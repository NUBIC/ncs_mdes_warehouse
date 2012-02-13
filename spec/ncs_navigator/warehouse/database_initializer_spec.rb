require File.expand_path('../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse
  describe DatabaseInitializer do
    describe '#replace_schema', :slow, :use_mdes do
      subject { DatabaseInitializer.new(spec_config) }
      let(:mdes_models) { spec_config.models_module.mdes_order }
      let(:mdes_table_names) { mdes_models.collect(&:mdes_table_name) }

      before do
        subject.set_up_repository(:both)
      end

      def table_names(schema)
        ::DataMapper.repository("mdes_warehouse_#{schema}").adapter.select(
          "SELECT table_name FROM information_schema.tables WHERE table_schema='public'")
      end

      it 'does not touch the reporting repository' do
        subject.drop_all(:reporting) # just to make sure
        subject.replace_schema
        table_names(:reporting).should == []
      end

      it 'creates all the MDES model tables' do
        subject.replace_schema
        (mdes_table_names - table_names(:working)).
          should == []
      end

      it 'creates the ancillary warehouse information tables' do
        subject.replace_schema
        table_names(:working).select { |n| n =~ /^wh_/ }.size.should == 2
      end

      describe 'with foreign keys' do
        let(:foreign_keys) {
          ::DataMapper.repository(:mdes_warehouse_working).adapter.select(
            %q{
               SELECT constraint_name, is_deferrable
               FROM information_schema.table_constraints
               WHERE constraint_schema='public'
                 AND constraint_type='FOREIGN KEY'
            })
        }

        before do
          subject.replace_schema
        end

        it 'creates them' do
          foreign_keys.should_not == []
        end

        it 'flags them as deferrable' do
          foreign_keys.collect(&:is_deferrable).uniq.should == %w(YES)
        end
      end

      describe 'including no-pii views' do
        def select_from_working(sql)
          ::DataMapper.repository(:mdes_warehouse_working).adapter.select(sql)
        end

        let(:pii_variables) {
          spec_config.mdes.transmission_tables.collect { |t|
            t.variables.reject { |v| v.pii.blank? }.collect { |v| [t.name, v.name].join('.') }
          }.flatten.sort
        }

        let(:nonpii_variables) {
          spec_config.mdes.transmission_tables.collect { |t|
            t.variables.select { |v| v.pii.blank? }.
              reject { |v| v.name == 'transaction_type' }.
              collect { |v| [t.name, v.name].join('.') }
          }.flatten.sort
        }

        let(:no_pii_views) {
            select_from_working(%q{
               SELECT table_name
               FROM information_schema.views
               WHERE table_schema='no_pii'
            })
        }

        let(:no_pii_view_column_usage) {
          select_from_working(%q(
            SELECT table_name || '.' || column_name
            FROM information_schema.view_column_usage
            WHERE view_schema='no_pii' AND table_schema='public'
          )).uniq.sort
        }

        before do
          subject.replace_schema
        end

        it 'creates a no-pii view for every table' do
          (mdes_table_names - no_pii_views).should == []
        end

        it 'does not include values for any PII variables in the views' do
          (pii_variables & no_pii_view_column_usage).should == []
        end

        it 'does include values for all non-PII variables in the views' do
          (nonpii_variables - no_pii_view_column_usage).should == []
        end
      end
    end
  end
end
