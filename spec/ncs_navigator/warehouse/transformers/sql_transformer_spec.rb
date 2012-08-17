require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe SqlTransformer do
    describe '.extract_statements' do
      it 'splits on semicolons' do
        SqlTransformer.extract_statements("SELECT 1; SELECT 2; SELECT 'A';").should == [
          'SELECT 1',
          'SELECT 2',
          "SELECT 'A'"
        ]
      end

      it 'includes the last statement even if it does not end with a semicolon' do
        SqlTransformer.extract_statements("SELECT 3; SELECT 7; SELECT 'B'").should == [
          'SELECT 3',
          'SELECT 7',
          "SELECT 'B'"
        ]
      end

      it 'ignores semicolons inside of string literals' do
        SqlTransformer.extract_statements("SELECT ';'; SELECT 7;").should == [
          "SELECT ';'",
          'SELECT 7'
        ]
      end

      it 'handles strings with escaped quotes properly' do
        SqlTransformer.extract_statements("SELECT 'Fred'';s'; SELECT '7';").should == [
          "SELECT 'Fred'';s'",
          "SELECT '7'"
        ]
      end

      it 'handles E-strings with escaped quotes properly'
    end

    let(:options) { { :adapter => mock('adapter') } }
    let(:transformer) { SqlTransformer.new(spec_config, options) }

    describe '#initialize' do
      it 'accepts an array of statements' do
        options[:statements] = ['SELECT 1', 'SELECT 8']

        transformer.statements.should == ['SELECT 1', 'SELECT 8']
      end

      it 'accepts and splits a string containing a script' do
        options[:script] = "SELECT 1; SELECT ';'"

        transformer.statements.should == ['SELECT 1', "SELECT ';'"]
      end

      it 'can read a script from a file' do
        filename = tmpdir + 'a_script.sql'

        filename.open('w') do |f|
          f.puts "SELECT 1;"
          f.puts "SELECT ';';"
        end

        options[:file] = filename.to_s

        transformer.statements.should == ['SELECT 1', "SELECT ';'"]
      end

      it 'accepts a name' do
        options[:statements] = []
        options[:name] = 'Foo'
        transformer.name.should == 'Foo'
      end

      it 'provides a default name' do
        options[:statements] = []
        transformer.name.should == 'SQL Transformer with 0 statements'
      end
    end

    describe '#transform', :use_database do
      let(:adapter) { mock('adapter') }

      let(:statements) {
        [
          'UPDATE a SET x=42',
          'UPDATE b SET y=42',
          'UPDATE c SET z=42'
        ]
      }

      let(:transformer) {
        SqlTransformer.new(spec_config, :statements => statements, :adapter => adapter)
      }

      let(:transform_status) {
        NcsNavigator::Warehouse::TransformStatus.memory_only('test')
      }

      def result(count)
        mock('result').tap do |m|
          m.stub!(:affected_rows).and_return(count)
        end
      end

      describe 'when successful' do
        before do
          adapter.should_receive(:execute).with(statements[0]).ordered.and_return(result(4))
          adapter.should_receive(:execute).with(statements[1]).ordered.and_return(result(7))
          adapter.should_receive(:execute).with(statements[2]).ordered.and_return(result(1))

          transformer.transform(transform_status)
        end

        it 'executes all statements in series' do
          # in before
        end

        it 'stores the total affected record count' do
          transform_status.record_count.should == (4 + 7 + 1)
        end
      end

      describe 'when there is an error' do
        before do
          adapter.should_receive(:execute).with(statements[0]).ordered.and_return(result(4))
          adapter.should_receive(:execute).with(statements[1]).ordered.and_raise('Give up now')
          adapter.should_not_receive(:execute).with(statements[2])

          transformer.transform(transform_status)
        end

        it 'stops on the first statement with an error' do
          # in before
        end

        it 'records a transform error' do
          transform_status.transform_errors.size.should == 1
        end

        describe 'the error' do
          let(:the_error) {
            transform_status.transform_errors.first
          }

          it 'has an appropriate message' do
            the_error.message.should =~
              /^Exception while executing SQL statement "UPDATE b SET y=42" \(2 of 3\).\s+RuntimeError: Give up now/
          end
        end

        it 'records the record count up to that point' do
          transform_status.record_count.should == 4
        end
      end
    end
  end
end
