# spec/rspec/sleeping_king_studios/comparators/data_comparator_spec.rb

require 'rspec/sleeping_king_studios/spec_helper'
require 'rspec/sleeping_king_studios/matchers/built_in/respond_to'

require 'rspec/sleeping_king_studios/comparators/data_comparator'

RSpec.describe RSpec::SleepingKingStudios::Comparators::DataComparator do
  let(:instance) { described_class.new }

  describe '#compare' do
    it { expect(instance).to respond_to(:compare).with(2..3).arguments }

    describe 'with uncomparable objects' do
      let(:klass) do
        Struct.new(:value) do
          def == other
            value == other.value
          end # method ==
        end # class
      end # let
      let(:first)  { klass.new('foo') }
      let(:second) { klass.new('foo') }

      it { expect(instance.compare first, second).to be false }
    end # describe

    describe 'with arrays' do
      describe 'with different counts' do
        let(:first)  { %w(foo bar) }
        let(:second) { %w(foo bar baz) }

        it { expect(instance.compare first, second).to be false }
      end # describe

      describe 'with the same count but different items' do
        let(:first)  { %w(foo bar) }
        let(:second) { %w(foo baz) }

        it { expect(instance.compare first, second).to be false }
      end # describe

      describe 'with the same items but in a different order' do
        let(:first)  { %w(foo bar baz) }
        let(:second) { %w(foo baz bar) }

        it { expect(instance.compare first, second).to be false }
      end # describe

      describe 'with the same items in the same order' do
        let(:first)  { %w(foo bar baz) }
        let(:second) { %w(foo bar baz) }

        it { expect(instance.compare first, second).to be true }
      end # describe
    end # describe

    describe 'with booleans' do
      describe 'with non-matching values' do
        it { expect(instance.compare true, false).to be false }
      end # describe

      describe 'with false values' do
        it { expect(instance.compare false, false).to be true }
      end # describe

      describe 'with true values' do
        it { expect(instance.compare true, true).to be true }
      end # describe
    end # describe

    describe 'with complex data structures' do
      let(:canonical) do
        { :posts => [
            { :riddle => 'What lies beyond the furthest reaches of the sky?',
              :answer => 'That which will lead the lost child back to her mother\'s arms. Exile.',
              :tags   => ['House Eraclea', 'Exile', 'the Guild']
            }, # end hash
            { :riddle => 'The waves that flow and dye the land gold.',
              :answer => 'The blessed breath that nurtures life. A land of wheat.',
              :tags   => ['House Dagobert', 'Anatoray', 'Disith']
            }, # end hash
            { :riddle => 'The path the angels descend upon.',
              :answer => 'The path of great winds. The Grand Stream.',
              :tags   => ['House Bassianus', 'the Grand Stream']
            }, # end hash
            { :riddle => 'What lies within the furthest depths of one\'s memory?',
              :answer => 'The place where all are born and where all will return. A blue star.',
              :tags   => ['House Hamilton', 'Earth']
            }  # end hash
          ] # end array
        } # end hash
      end # let
      let(:copy) { SleepingKingStudios::Tools::ObjectTools.deep_dup canonical }

      describe 'with an exact match' do
        let(:first)  { canonical }
        let(:second) { copy }

        it { expect(instance.compare first, second).to be true }

        describe 'with :ordered => false' do
          it { expect(instance.compare first, second, :ordered => false).to be true }
        end # describe
      end # describe

      describe 'with missing tags' do
        let(:first) { canonical }
        let(:second) do
          copy.tap do |hsh|
            hsh[:posts].each do |post|
              ary = post[:tags]
              ary.reject! { |str| str =~ /\AHouse/ }
            end # each
          end # tap
        end # let

        it { expect(instance.compare first, second).to be false }

        describe 'with :ordered => false' do
          it { expect(instance.compare first, second, :ordered => false).to be false }
        end # describe
      end # describe

      describe 'with unordered posts' do
        let(:first) { canonical }
        let(:second) do
          copy.tap do |hsh|
            ary = hsh[:posts]
            ary.push(ary.shift)
          end # tap
        end # let

        it { expect(instance.compare first, second).to be false }

        describe 'with :ordered => false' do
          it { expect(instance.compare first, second, :ordered => false).to be true }
        end # describe
      end # describe

      describe 'with unordered tags' do
        let(:first) { canonical }
        let(:second) do
          copy.tap do |hsh|
            hsh[:posts].each do |post|
              ary = post[:tags]
              ary.push(ary.shift)
            end # each
          end # tap
        end # let

        it { expect(instance.compare first, second).to be false }

        describe 'with :ordered => false' do
          it { expect(instance.compare first, second, :ordered => false).to be true }
        end # describe
      end # describe
    end # describe

    describe 'with hashes' do
      describe 'with mixed string and symbol keys' do
        describe 'with non-matching keys' do
          let(:first)  { { :foo  => 'foo', :bar => 'bar' } }
          let(:second) { { 'foo' => 'foo', 'baz' => 'baz' } }

          it { expect(instance.compare first, second).to be false }
        end # describe

        describe 'with matching keys and non-matching values' do
          let(:first)  { { :foo  => 'foo', :bar => 'bar' } }
          let(:second) { { 'foo' => 'foo', 'bar' => "Rick's Cafe" } }

          it { expect(instance.compare first, second).to be false }
        end # describe

        describe 'with matching keys and values' do
          let(:first)  { { :foo  => 'foo', :bar  => 'bar', :baz  => 'baz' } }
          let(:second) { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }

          it { expect(instance.compare first, second).to be false }
        end # describe
      end # describe

      describe 'with string keys' do
        describe 'with non-matching keys' do
          let(:first)  { { 'foo' => 'foo', 'bar' => 'bar' } }
          let(:second) { { 'foo' => 'foo', 'baz' => 'baz' } }

          it { expect(instance.compare first, second).to be false }
        end # describe

        describe 'with matching keys and non-matching values' do
          let(:first)  { { 'foo' => 'foo', 'bar' => 'bar' } }
          let(:second) { { 'foo' => 'foo', 'bar' => "Rick's Cafe" } }

          it { expect(instance.compare first, second).to be false }
        end # describe

        describe 'with matching keys and values' do
          let(:first)  { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }
          let(:second) { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }

          it { expect(instance.compare first, second).to be true }
        end # describe
      end # describe

      describe 'with symbol keys' do
        describe 'with non-matching keys' do
          let(:first)  { { :foo => 'foo', :bar => 'bar' } }
          let(:second) { { :foo => 'foo', :baz => 'baz' } }

          it { expect(instance.compare first, second).to be false }
        end # describe

        describe 'with matching keys and non-matching values' do
          let(:first)  { { :foo => 'foo', :bar => 'bar' } }
          let(:second) { { :foo => 'foo', :bar => "Rick's Cafe" } }

          it { expect(instance.compare first, second).to be false }
        end # describe

        describe 'with matching keys and values' do
          let(:first)  { { :foo => 'foo', :bar => 'bar', :baz => 'baz' } }
          let(:second) { { :foo => 'foo', :bar => 'bar', :baz => 'baz' } }

          it { expect(instance.compare first, second).to be true }
        end # describe
      end # describe
    end # describe

    describe 'with floats' do
      describe 'with non-matching values' do
        it { expect(instance.compare 1.0, 1.1).to be false }
      end # describe

      describe 'with matching values' do
        it { expect(instance.compare 2.0, 2.0).to be true }
      end # describe
    end # describe

    describe 'with integers' do
      describe 'with non-matching values' do
        it { expect(instance.compare 21, 33).to be false }
      end # describe

      describe 'with matching values' do
        it { expect(instance.compare 42, 42).to be true }
      end # describe
    end # describe

    describe 'with nils' do
      it { expect(instance.compare nil, nil).to be true }
    end # describe

    describe 'with strings' do
      describe 'with non-matching values' do
        let(:first)  { 'What lies beyond the farthest reaches of the sky?' }
        let(:second) { "That which will lead the lost child back to her mothers arms. Exile." }

        it { expect(instance.compare first, second).to be false }
      end # describe

      describe 'with matching values' do
        let(:first)  { 'Some things we believe in because they are real. Others are real because we believe in them.' }
        let(:second) { 'Some things we believe in because they are real. Others are real because we believe in them.' }

        it { expect(instance.compare first, second).to be true }
      end # describe
    end # describe

    describe 'with symbols' do
      describe 'with non-matching values' do
        it { expect(instance.compare :athena, :apollo).to be false }
      end # describe

      describe 'with matching values' do
        it { expect(instance.compare :loki, :loki).to be true }
      end # describe
    end # describe
  end # describe
end # describe
