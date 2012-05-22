require 'spec_helper'

module NcsNavigator::Warehouse
  describe StringifyTrace do
    describe '#stringify_trace' do
      it 'is available when mixed in' do
        host = Class.new do
          include StringifyTrace

          def m
            stringify_trace(['foo'])
          end
        end.new

        lambda { host.m }.should_not raise_error
      end
    end

    describe '.stringify_trace' do
      let(:simple_trace) {
        [
          "(irb):2:in `irb_binding'",
          "workspace.rb:80:in `eval'",
          "foo/caller.rb:1024:in `<main>'"
        ]
      }

      it 'aligns everything nicely' do
        StringifyTrace.stringify_trace(simple_trace).should == <<-EXPECTED.chomp
        (irb):   2:in `irb_binding'
 workspace.rb:  80:in `eval'
foo/caller.rb:1024:in `<main>'
EXPECTED
      end

      it 'includes lines that cannot be parsed' do
        StringifyTrace.stringify_trace(simple_trace + ['something up over here']).
          should == <<-EXPECTED.chomp
        (irb):   2:in `irb_binding'
 workspace.rb:  80:in `eval'
foo/caller.rb:1024:in `<main>'
something up over here
EXPECTED
      end

      it 'aligns lines without specific context info' do
        StringifyTrace.stringify_trace(simple_trace + ['bar/zap.rb:423']).
          should == <<-EXPECTED.chomp
        (irb):   2:in `irb_binding'
 workspace.rb:  80:in `eval'
foo/caller.rb:1024:in `<main>'
   bar/zap.rb: 423
EXPECTED
      end
    end
  end
end

