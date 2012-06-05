require 'spec_helper'

module NcsNavigator::Warehouse::Transformers
  describe Filters do
    let(:filter_one)   { StubFilter.new('one') }
    let(:filter_two)   { StubFilter.new('two') }
    let(:filter_three) { StubFilter.new('three') }

    describe '#initialize' do
      it 'sets the #filters attribute' do
        Filters.new([filter_two, filter_one]).filters.should == [filter_two, filter_one]
      end

      it 'rejects objects that do not have a call method' do
        lambda { Filters.new([filter_three, Object.new]) }.
          should raise_error(/Filter 1 \(Object\) does not have a call method/)
      end
    end

    describe '#call' do
      describe 'with some filters' do
        let(:filters) { Filters.new([filter_one, filter_two, filter_three]) }

        it 'feeds the result from the each into the next' do
          filter_one.should_receive(:call).with([:foo]).and_return([:foo, :bar])
          filter_two.should_receive(:call).with([:foo, :bar]).and_return([:bar])
          filter_three.should_receive(:call).with([:bar]).and_return([:quux])

          filters.call([:foo]).should == [:quux]
        end

        it 'treats a nil return as []' do
          filter_one.should_receive(:call).with([:foo]).and_return(nil)
          filter_two.should_receive(:call).with([]).and_return([:bar])

          filters.call([:foo])
        end

        it 'treats false as a value' do
          filter_one.should_receive(:call).with([false])

          filters.call(false)
        end

        it 'wraps a single input value in an array' do
          filter_one.should_receive(:call).with([:foo])

          filters.call(:foo)
        end
      end

      describe 'with no filters' do
        let(:filters) { Filters.new([]) }

        it 'returns the input' do
          filters.call([:foo]).should == [:foo]
        end

        it 'normalizes nil to []' do
          filters.call(nil).should == []
        end

        it 'wraps a single input value in an array' do
          filters.call(:bar).should == [:bar]
        end
      end
    end

    describe 'enumerableness' do
      let(:filters) { Filters.new([filter_one, filter_two, filter_three]) }

      it 'is Enumerable' do
        Filters.ancestors.should include(::Enumerable)
      end

      it 'delegates #each to the filter list' do
        filters.collect(&:name).should == %w(one two three)
      end
    end

    class StubFilter
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def call(records)
        records
      end

      def inspect
        "#<StubFilter #{name.inspect}>"
      end
    end
  end
end
