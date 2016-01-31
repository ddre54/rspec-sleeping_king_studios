# spec/rspec/sleeping_king_studios/concerns/comparable/comparator_spec.rb

require 'rspec/sleeping_king_studios/spec_helper'
require 'rspec/sleeping_king_studios/matchers/built_in/respond_to'

require 'rspec/sleeping_king_studios/concerns/comparable/comparator'

RSpec.describe RSpec::SleepingKingStudios::Concerns::Comparable::Comparator do
  shared_context 'with a comparator subclass' do
    let(:described_class) { Class.new super() }
  end # shared_context

  let(:instance) { described_class.new }

  describe '::compare' do
    shared_examples 'should require a method name or block' do
      describe 'with an empty string' do
        it 'should raise an error' do
          expect {
            described_class.compare *types, ''
          }.to raise_error ArgumentError, "method name can't be blank"
        end # it
      end # describe

      describe 'with an empty symbol' do
        it 'should raise an error' do
          expect {
            described_class.compare *types, :''
          }.to raise_error ArgumentError, "method name can't be blank"
        end # it
      end # describe

      describe 'with an object' do
        it 'should raise an error' do
          expect {
            described_class.compare *types, { :foo => :bar }
          }.to raise_error ArgumentError, 'method name must be a string or symbol'
        end # it
      end # describe

      describe 'with a method name' do
        include_context 'with a comparator subclass'

        let(:method_name) { :comparison_method }

        before(:example) do
          described_class.compare *types, method_name
        end # before example

        context 'with no method defined' do
          it 'should raise an error' do
            expect {
              instance.compare *values
            }.to raise_error NoMethodError, /undefined method `comparison_method'/
          end # it
        end # context

        context 'with a defined method' do
          before(:each) do
            described_class.send :define_method, method_name, &comparison
          end # before each

          include_examples 'should define a comparison'
        end # context
      end # describe

      describe 'with a block' do
        include_context 'with a comparator subclass'

        before(:example) do
          described_class.compare *types, &comparison
        end # before example

        include_examples 'should define a comparison'
      end # describe
    end # shared_examples

    it { expect(described_class).to respond_to(:compare).with(1..3).arguments.and_a_block }

    describe 'with a class' do
      shared_examples 'should define a comparison' do
        let(:an_object_named_string) { double(:name => 'String', :is_a? => ->(klass) { klass == Class }) }

        describe 'with non-matching items' do
          it { expect(instance.compare String, Symbol).to be false }
        end # describe

        describe 'with matching items' do
          it { expect(instance.compare String, an_object_named_string).to be true }
        end # describe
      end # shared_examples

      let(:types)  { [Class] }
      let(:values) { [String, Symbol] }
      let(:comparison) do
        ->(u, v, options) {
          u.name == v.name
        } # end lambda
      end # let

      it 'should raise an error' do
        expect {
          described_class.compare Class
        }.to raise_error ArgumentError, 'must provide a method name or block'
      end # it

      include_examples 'should require a method name or block'
    end # describe

    describe 'with two classes' do
      shared_examples 'should define a comparison' do
        describe 'with non-matching items' do
          it { expect(instance.compare 'greetings', :hello).to be false }
        end # describe

        describe 'with matching items' do
          it { expect(instance.compare 'greetings', :greetings).to be true }
        end # describe
      end # shared_examples

      let(:types)  { [String, Symbol] }
      let(:values) { ['greetings', :greetings] }
      let(:comparison) do
        ->(u, v, options) {
          u == v.to_s
        } # end lambda
      end # let

      it 'should raise an error' do
        expect {
          described_class.compare String, Symbol
        }.to raise_error ArgumentError, 'must provide a method name or block'
      end # it

      include_examples 'should require a method name or block'
    end # describe
  end # describe

  describe '#compare' do
    it { expect(instance).to respond_to(:compare).with(2..3).arguments }

    it 'should raise an error' do
      expect {
        instance.compare nil, nil
      }.to raise_error RSpec::SleepingKingStudios::Concerns::Comparable::UnimplementedComparisonError,
        'no comparison is defined to compare nil with nil'
    end # it

    context 'with a defined comparison with one predicate' do
      include_context 'with a comparator subclass'

      before(:example) do
        described_class.compare String do |u, v, options|
          u.length == v.length
        end # compare
      end # before

      describe 'with non-matching items' do
        it { expect(instance.compare 'abc', 'abra kadabra').to be false }
      end # describe

      describe 'with matching items' do
        it { expect(instance.compare 'abc', 'def').to be true }
      end # describe

      context 'with an overriden comparison' do
        before(:example) do
          described_class.compare String do |u, v, options|
            u[0] == v[0]
          end # compare
        end # before

        describe 'with non-matching items' do
          it { expect(instance.compare 'abc', 'def').to be false }
        end # describe

        describe 'with matching items' do
          it { expect(instance.compare 'abc', 'abra kadabra').to be true }
        end # describe
      end # describe

      context 'with a comparison defined on a superclass' do
        let(:subclass) { Class.new(described_class) }
        let(:instance) { subclass.new }

        describe 'with non-matching items' do
          it { expect(instance.compare 'abc', 'abra kadabra').to be false }
        end # describe

        describe 'with matching items' do
          it { expect(instance.compare 'abc', 'def').to be true }
        end # describe
      end # describe
    end # describe

    context 'with a defined comparison with two predicates' do
      include_context 'with a comparator subclass'

      before(:example) do
        described_class.compare String, Symbol do |u, v, options|
          u.length == v.length
        end # compare
      end # before

      describe 'with non-matching items' do
        it { expect(instance.compare 'abc', :'abra kadabra').to be false }
      end # describe

      describe 'with matching items' do
        it { expect(instance.compare 'abc', :def).to be true }
      end # describe

      describe 'with non-matching items in reverse order' do
        it { expect(instance.compare :'abra kadabra', 'abc').to be false }
      end # describe

      describe 'with matching items in reverse order' do
        it { expect(instance.compare :def, 'abc').to be true }
      end # describe
    end # describe
  end # describe
end # describe
