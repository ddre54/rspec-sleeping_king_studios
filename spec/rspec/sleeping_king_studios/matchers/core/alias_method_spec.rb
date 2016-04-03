# spec/rspec/sleeping_king_studios/matchers/core/alias_method_spec.rb

require 'rspec/sleeping_king_studios/spec_helper'
require 'rspec/sleeping_king_studios/concerns/focus_examples'
require 'rspec/sleeping_king_studios/concerns/wrap_examples'
require 'rspec/sleeping_king_studios/examples/rspec_matcher_examples'

require 'rspec/sleeping_king_studios/matchers/core/alias_method'

describe RSpec::SleepingKingStudios::Matchers::Core::AliasMethodMatcher do
  extend  RSpec::SleepingKingStudios::Concerns::WrapExamples
  extend  RSpec::SleepingKingStudios::Concerns::FocusExamples
  include RSpec::SleepingKingStudios::Examples::RSpecMatcherExamples

  shared_context 'with a new method name' do
    let(:new_method_name) { :new_method }
    let(:instance)        { super().as new_method_name }
  end # shared_context

  let(:example_group) { self }

  it { expect(example_group).to respond_to(:alias_method).with(1).argument }
  it { expect(example_group.alias_method :aliased_method).to be_a described_class }

  let(:old_method_name) { :old_method }
  let(:instance)        { described_class.new old_method_name }

  describe '#as' do
    let(:new_method_name) { :new_method }

    it { expect(instance).to respond_to(:as).with(1).arguments }

    it { expect(instance.as new_method_name).to be instance }
  end # describe with

  describe '#description' do
    it { expect(instance).to respond_to(:description).with(0).arguments }

    it { expect(instance.description).to be == "alias :#{old_method_name}" }

    wrap_context 'with a new method name' do
      it { expect(instance.description).to be == "alias :#{old_method_name} as :#{new_method_name}" }
    end # context
  end # describe

  describe '#matches?' do
    let(:actual_class) do
      Class.new do
        def to_s
          '#<Actual>'
        end # method to_s
        alias_method :inspect, :to_s
      end # class
    end # let
    let(:actual) { actual_class.new }

    it { expect(instance).to respond_to(:matches?).with(1).argument }

    shared_examples 'should require a new method name' do
      it 'should raise an error' do
        expect {
          instance.matches? actual
        }.to raise_error ArgumentError, 'must specify a new method name'
      end # it
    end # shared_examples

    include_examples 'should require a new method name'

    describe 'with an actual that does not respond to the old method' do
      include_examples 'should require a new method name'

      wrap_context 'with a new method name' do
        let(:failure_message) do
          "expected #{actual.inspect} to alias :#{old_method_name} as "\
          ":#{new_method_name}, but did not respond to :#{old_method_name}"
        end # let

        include_examples 'should fail with a positive expectation'

        include_examples 'should pass with a negative expectation'
      end # wrap_context
    end # describe

    describe 'with an actual that responds to the old method' do
      before(:each) do
        old_name = old_method_name

        actual_class.send :define_method, old_name, ->() {}
      end # before each

      include_examples 'should require a new method name'

      wrap_context 'with a new method name' do
        let(:failure_message) do
          "expected #{actual.inspect} to alias :#{old_method_name} as "\
          ":#{new_method_name}, but did not respond to :#{new_method_name}"
        end # let

        include_examples 'should fail with a positive expectation'

        include_examples 'should pass with a negative expectation'
      end # wrap_context
    end # describe

    describe 'with an actual that responds to the old method and the new method' do
      let(:new_method_name) { :new_method }

      before(:each) do
        old_name = old_method_name
        new_name = new_method_name

        actual_class.send :define_method, old_name, ->() {}
        actual_class.send :define_method, new_name, ->() {}
      end # before each

      include_examples 'should require a new method name'

      wrap_context 'with a new method name' do
        let(:failure_message) do
          "expected #{actual.inspect} to alias :#{old_method_name} as "\
          ":#{new_method_name}, but :#{old_method_name} and "\
          ":#{new_method_name} are different methods"
        end # let

        include_examples 'should fail with a positive expectation'

        include_examples 'should pass with a negative expectation'
      end # wrap_context
    end # describe

    describe 'with an actual that aliases the old method as the new method' do
      let(:new_method_name) { :new_method }

      before(:each) do
        old_name = old_method_name
        new_name = new_method_name

        actual_class.send :define_method, old_name, ->() {}
        actual_class.send :alias_method,  new_name, old_name
      end # before each

      include_examples 'should require a new method name'

      wrap_context 'with a new method name' do
        let(:failure_message_when_negated) do
          "expected #{actual.inspect} not to alias :#{old_method_name} as "\
          ":#{new_method_name}"
        end # let

        include_examples 'should pass with a positive expectation'

        include_examples 'should fail with a negative expectation'
      end # wrap_context
    end # describe
  end # describe
end # describe
