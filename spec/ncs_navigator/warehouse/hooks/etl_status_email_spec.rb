require File.expand_path('../../../../spec_helper', __FILE__)

module NcsNavigator::Warehouse::Hooks
  describe EtlStatusEmail do
    let(:config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |c|
        c.log_file = tmpdir + "#{File.basename(__FILE__)}.log"
        c.output_level = :quiet
      end
    }

    let(:mailer) {
      EtlStatusEmail.new(:to => to)
    }

    let(:to) {
      ['jane@gcsc.net', 'joe@northwestern.edu']
    }

    let(:statuses) {
      [
        NcsNavigator::Warehouse::TransformStatus.memory_only('SP',
          :start_time => Time.parse('2011-04-03T00:06:23'),
          :end_time   => Time.parse('2011-04-03T00:53:00'),
          :record_count => 5,
          :position => 0),
        NcsNavigator::Warehouse::TransformStatus.memory_only('Co',
          :start_time => Time.parse('2011-04-03T00:53:01'),
          :end_time   => Time.parse('2011-04-03T02:32:32'),
          :record_count => 11,
          :position => 1)
      ]
    }

    let(:hook_args) {
      {
        :configuration => config,
        :transform_statuses => statuses
      }
    }

    let(:message) { ActionMailer::Base.deliveries.first }

    before do
      config.set_up_action_mailer
      ActionMailer::Base.delivery_method = :test
    end

    after do
      ActionMailer::Base.deliveries.clear
    end

    shared_examples 'an ETL result call' do
      it 'sends an e-mail message' do
        ActionMailer::Base.deliveries.size.should == 1
      end

      it 'sends the message to the configured addresses' do
        message.to.should == to
      end

      it 'sends the message to the appropriate people based on their staff roles' do
        pending 'would be nice: #2083'
      end

      describe 'the message content' do
        it 'includes the duration' do
          message.body.should =~ /2:26:09/
        end

        it 'includes the record count' do
          message.body.should =~ /16 total records/
        end

        it 'includes a link to the warehouse dashboard' do
          pending "there isn't one"
        end
      end
    end

    describe '#etl_succeeded' do
      before do
        mailer.etl_succeeded(hook_args)
      end

      include_examples 'an ETL result call'

      describe 'the message subject' do
        it 'indicates that the ETL succeeded' do
          message.subject.should == '[NCS Navigator] Warehouse load successful'
        end
      end

      describe 'the message content' do
        it 'indicates that the ETL succeeded' do
          message.body.should =~ /All transformations executed successfully./
        end
      end
    end

    describe '#etl_failed' do
      before do
        statuses[1].transform_errors <<
          NcsNavigator::Warehouse::TransformError.new(:message => 'Not good enough')

        mailer.etl_failed(hook_args)
      end

      include_examples 'an ETL result call'

      describe 'the message subject' do
        it 'indicates that the ETL failed' do
          message.subject.should == '[NCS Navigator] Warehouse load failed'
        end
      end

      describe 'the message content' do
        it 'indicates that the ETL failed' do
          message.body.
            should =~ /1 transformation executed successfully.\s+1 transformation failed./
        end
      end
    end
  end
end

