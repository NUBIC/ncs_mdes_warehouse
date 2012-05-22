require 'spec_helper'

module NcsNavigator::Warehouse::PostgreSQL
  describe Pgpass do
    let(:home) { tmpdir('home') }
    let(:file) { home + '.pgpass' }

    before do
      @original_home, ENV['HOME'] = ENV['HOME'], home
    end

    after do
      ENV['HOME'] = @original_home
    end

    describe '#file' do
      it 'defaults to $HOME/.pgpass' do
        Pgpass.new.file.should == file
      end
    end

    describe '.line' do
      subject { Pgpass.line entry }
      let(:entry) {
        {
          'username' => 'warehouse',
          'password' => 'volt',
          'database' => 'ignored'
        }
      }

      it 'includes defaults for host and port if not set' do
        subject.should == %w(localhost 5432 * warehouse volt)
      end

      it 'uses an explicit host if available' do
        entry['host'] = 'ncs_db'
        subject.should == %w(ncs_db 5432 * warehouse volt)
      end

      it 'uses an explicit port if available' do
        entry['port'] = 5439
        subject.should == %w(localhost 5439 * warehouse volt)
      end

      it 'fails without a username' do
        entry.delete 'username'
        lambda { subject }.should raise_error(/No username in configuration/)
      end

      it 'fails without a password' do
        entry.delete 'password'
        lambda { subject }.should raise_error(/No password in configuration/)
      end
    end

    describe '#update' do
      subject { Pgpass.new }
      let(:entry) {
        {
          'username' => 'mw',
          'password' => 'fishes',
          'host' => 'ncsdb',
          'port' => 5500,
          'database' => 'mw_r'
        }
      }
      let(:lines) {
        file.readlines.collect { |l| l.chomp.split ':' }
      }
      let(:expected_line) { "ncsdb:5500:*:mw:fishes\n" }

      describe 'when the file exists' do
        describe 'and the same line exists' do
          before do
            file.open('w') do |f|
              f.puts 'somewhere:5400:*:aguy:five'
              f.puts 'ncsdb:5500:*:mw:fishes'
              f.puts 'somewhere:5400:*:someoneelse:yet'
            end

            subject.update(entry)
          end

          it 'does nothing' do
            lines.collect { |l| l[3] }.should == %w(aguy mw someoneelse)
          end
        end

        describe 'and a similar line with a different password exists' do
          before do
            file.open('w') do |f|
              f.puts 'somewhere:5400:*:aguy:five'
              f.puts 'ncsdb:5500:*:mw:shark'
              f.puts 'ncsdb:5500:*:someoneelse:fred'
              f.puts 'somewhere:5400:*:someoneelse:yet'
            end

            subject.update(entry)
          end

          it 'updates the password' do
            file.readlines[1].should == expected_line
          end

          it 'leaves other entries alone' do
            lines.collect { |l| l[4] }.should == %w(five fishes fred yet)
          end
        end

        describe 'and no similar entry exists' do
          before do
            file.open('w') do |f|
              f.puts 'somewhere:5400:*:aguy:five'
              f.puts 'ncsdb:5500:*:someoneelse:fred'
              f.puts 'somewhere:5400:*:someoneelse:yet'
            end

            subject.update(entry)
          end

          it 'adds the entry' do
            file.readlines.last.should == expected_line
          end

          it 'leaves the other entries alone' do
            lines.collect { |l| l[0] }.should == %w(somewhere ncsdb somewhere ncsdb)
          end
        end
      end

      describe 'when the file does not exist' do
        before do
          file.exist?.should be_false

          subject.update(entry)
        end

        it 'creates the file' do
          file.exist?.should be_true
        end

        it 'sets the permissions to user-rw only' do
          `ls -al '#{file}'`.should =~ /^-rw------/
        end

        it 'adds the appropriate entry' do
          file.readlines.should == [expected_line]
        end
      end

      describe 'when the directory does not exist' do
        before do
          home.rmdir
        end

        it 'fails' do
          lambda { subject.update(entry) }.should(
            raise_error %r{Cannot create #{home}/.pgpass})
        end
      end

      describe 'when the directory is not writable' do
        before do
          home.chmod(0500)
        end

        it 'fails' do
          lambda { subject.update(entry) }.should(
            raise_error %r{Cannot create #{home}/.pgpass})
        end
      end

      describe 'when the file exists but is not writable' do
        before do
          file.open('w') { |f| }
          file.chmod(0500)
        end

        it 'fails' do
          lambda { subject.update(entry) }.should(
            raise_error %r{Cannot update #{home}/.pgpass})
        end
      end
    end
  end
end
