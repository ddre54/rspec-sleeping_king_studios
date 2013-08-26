# spec/rspec/sleeping_king_studios/matchers/built_in/respond_to_spec.rb

require 'rspec/sleeping_king_studios/spec_helper'
require 'rspec/sleeping_king_studios/matchers/base_matcher_helpers'

require 'rspec/sleeping_king_studios/matchers/built_in/respond_to'

describe RSpec::SleepingKingStudios::Matchers::BuiltIn::RespondToMatcher do
  include RSpec::SleepingKingStudios::Matchers::BaseMatcherHelpers

  let(:example_group) { self }
  let(:identifier)    { :foo }
  
  # Paging Douglas Hofstadter, or possibly Xzibit...
  specify { expect(example_group).to respond_to(:respond_to).with(1).arguments }
  specify { expect(example_group.respond_to identifier).to be_a described_class }

  let(:instance) { described_class.new identifier }

  it_behaves_like RSpec::SleepingKingStudios::Matchers::BaseMatcher

  describe "#with" do
    specify { expect(instance).to respond_to(:with).with(0..2).arguments }
    specify { expect(instance.with).to be instance }
  end # describe
  
  describe "#and" do
    specify { expect(instance).to respond_to(:and).with(0).arguments }
    specify { expect(instance.and).to be instance }
  end # describe
  
  describe "#a_block" do
    specify { expect(instance).to respond_to(:a_block).with(0).arguments }
    specify { expect(instance.a_block).to be instance }
  end # describe

  <<-SCENARIOS
    When there is no matching method,
      Evaluates to false with should message "to respond to".
    When there is a matching method,
      And there are no argument bounds,
        Evaluates to true with should_not message "not to respond to".
      And there is a set of arguments,
        And the method accepts that set of arguments,
          Evaluates to true with should_not message "not to respond to with (count) arguments".
        And the method requires more or fewer regular arguments,
          Evaluates to false with should message "to respond to with (count) arguments".
      And the ruby version is 2.0.0 or higher,
        And there is a set of keywords,
          And the method accepts that set of keywords,
            Evaluates to true with should_not message "not to respond to with keywords".
          And the method does not accept that set of arguments,
            Evaluates to false with should message "to respond to with key keywords"
      And there is a block provided,
        And the method expects a block,
          Evaluates to true with should_not message "not to respond to with a block".
        And the method does not expect a block,
          Evaluates to false with should message "to respond_to with a block".
  SCENARIOS

  describe 'with no matching method' do
    let(:actual) { Object.new }

    specify { expect(instance).to fail_with_actual(actual).
      with_message "expected #{actual.inspect} to respond to #{identifier.inspect}" }
  end # describe

  describe 'with a matching method with no arguments' do
    let(:actual) do
      Class.new.tap { |klass| klass.send :define_method, identifier, lambda {} }.new
    end # let

    specify 'with no arguments' do
      expect(instance.with(0).arguments).to pass_with_actual(actual).
        with_message "expected #{actual} not to respond to :#{identifier} with 0 arguments"
    end # specify

    specify 'with too many arguments' do
      failure_message = "expected #{actual.inspect} to respond to " +
        "#{identifier.inspect} with arguments:\n" +
        "  expected at most 0 arguments, but received 1"
      expect(instance.with(1).arguments).to fail_with_actual(actual).
        with_message failure_message
    end # specify

    specify 'with a block' do
      failure_message = "expected #{actual.inspect} to respond to " +
        "#{identifier.inspect} with arguments:\n" +
        "  unexpected block"
      expect(instance.with.a_block).to fail_with_actual(actual).
        with_message failure_message
    end # specify
  end # describe

  describe 'with a matching method with required arguments' do
    let(:actual) do
      Class.new.tap { |klass| klass.send :define_method, identifier, lambda { |a, b, c = nil| } }.new
    end # let

    specify 'with not enough arguments' do
      failure_message = "expected #{actual.inspect} to respond to " +
        "#{identifier.inspect} with arguments:\n" +
        "  expected at least 2 arguments, but received 1"
      expect(instance.with(1).arguments).to fail_with_actual(actual).
        with_message failure_message
    end # specify

    specify 'with enough arguments' do
      expect(instance.with(3).arguments).to pass_with_actual(actual).
        with_message "expected #{actual} not to respond to :#{identifier} with 3 arguments"
    end # specify

    specify 'with too many arguments' do
      failure_message = "expected #{actual.inspect} to respond to " +
        "#{identifier.inspect} with arguments:\n" +
        "  expected at most 3 arguments, but received 5"
      expect(instance.with(5).arguments).to fail_with_actual(actual).
        with_message failure_message
    end # specify
  end # describe

  describe 'with a matching method with variadic arguments' do
    let(:actual) do
      Class.new.tap { |klass| klass.send :define_method, identifier, lambda { |a, b, c, *rest| } }.new
    end # let

    specify 'with not enough arguments' do
      failure_message = "expected #{actual.inspect} to respond to " +
        "#{identifier.inspect} with arguments:\n" +
        "  expected at least 3 arguments, but received 2"
      expect(instance.with(2).arguments).to fail_with_actual(actual).
        with_message failure_message
    end # specify

    specify 'with an excessive number of arguments' do
      expect(instance.with(9001).arguments).to pass_with_actual(actual).
        with_message "expected #{actual} not to respond to :#{identifier} with 9001 arguments"
    end # specify
  end # describe

  if RUBY_VERSION >= "2.0.0"
    describe 'with a matching method with keywords' do
      let(:actual) do
        # class-eval hackery to avoid syntax errors on pre-2.0.0 systems
        Class.new.tap { |klass| klass.send :class_eval, %Q(klass.send :define_method, :#{identifier}, lambda { |a: true, b: true| }) }.new
      end # let

      specify 'with no keywords' do
        expect(instance).to pass_with_actual(actual).
          with_message "expected #{actual} not to respond to :#{identifier}"
      end # specify

      specify 'with valid keywords' do
        expect(instance.with(0, :a, :b)).to pass_with_actual(actual).
          with_message "expected #{actual} not to respond to :#{identifier} with 0 arguments and keywords :a, :b"
      end # specify

      specify 'with invalid keywords' do
        failure_message = "expected #{actual.inspect} to respond to " +
          "#{identifier.inspect} with arguments:\n" +
          "  unexpected keywords :c, :d"
        expect(instance.with(0, :c, :d)).to fail_with_actual(actual).
          with_message failure_message
      end # specify

      specify 'with valid keywords and unspecified arguments' do
        expect(instance.with(:a, :b)).to pass_with_actual(actual).
          with_message "expected #{actual} not to respond to :#{identifier} with keywords :a, :b"
      end # specify

      specify 'with invalid keywords and unspecified arguments' do
        failure_message = "expected #{actual.inspect} to respond to " +
          "#{identifier.inspect} with arguments:\n" +
          "  unexpected keywords :c, :d"
        expect(instance.with(:c, :d)).to fail_with_actual(actual).
          with_message failure_message
      end # specify
    end # describe

    describe 'with a matching method with variadic keywords' do
      let(:actual) do
        # class-eval hackery to avoid syntax errors on pre-2.0.0 systems
        Class.new.tap { |klass| klass.send :class_eval, %Q(klass.send :define_method, :#{identifier}, lambda { |a: true, b: true, **params| }) }.new
      end # let

      specify 'with no keywords' do
        expect(instance).to pass_with_actual(actual).
          with_message "expected #{actual} not to respond to :#{identifier}"
      end # specify

      specify 'with valid keywords' do
        expect(instance.with(0, :a, :b)).to pass_with_actual(actual).
          with_message "expected #{actual} not to respond to :#{identifier} with 0 arguments and keywords :a, :b"
      end # specify

      specify 'with random keywords' do
        expect(instance.with(0, :c, :d)).to pass_with_actual(actual).
          with_message "expected #{actual} not to respond to :#{identifier} with 0 arguments and keywords :c, :d"
      end # specify
    end # describe
  end # if

  describe 'with a matching method that expects a block' do
    let(:actual) do
      Class.new.tap { |klass| klass.send :define_method, identifier, lambda { |&block| yield } }.new
    end # let

    specify 'with no block' do
      expect(instance).to pass_with_actual(actual).
        with_message "expected #{actual} not to respond to :#{identifier}"
    end # specify

    specify 'with a block' do
      expect(instance.with.a_block).to pass_with_actual(actual).
        with_message "expected #{actual} not to respond to :#{identifier} with a block"
    end # specify
  end # describe
end # describe
