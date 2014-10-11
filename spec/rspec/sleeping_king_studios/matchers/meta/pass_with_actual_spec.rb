# spec/rspec/sleeping_king_studios/matchers/rspec/pass_with_actual_spec.rb

require 'rspec/sleeping_king_studios/spec_helper'

require 'rspec/sleeping_king_studios/matchers/meta/pass_with_actual'

describe RSpec::SleepingKingStudios::Matchers::Meta::PassWithActualMatcher do
  let(:example_group) { self }
  let(:actual)        { nil }
  
  it { expect(example_group).to respond_to(:pass_with_actual).with(1).arguments }
  it { expect(example_group.pass_with_actual actual).to be_a described_class }

  let(:instance) { described_class.new actual }

  describe '#message' do
    it { expect(instance).to respond_to(:message).with(0).arguments }
  end # describe

  describe "#with_message" do
    let(:expected_message) { "my hovercraft is full of eels" }

    it { expect(instance).to respond_to(:with_message).with(1).arguments }
    it { expect(instance.with_message expected_message).to be instance }
    it { expect(instance.with_message(expected_message).message).to be == expected_message }
  end # describe

  <<-SCENARIOS
    When given a matcher that evaluates to true,
      And not given a should_not message,
        Evaluates to true.
      And given a correct should_not message,
        Evaluates to true.
      And given an incorrect should_not message,
        Evaluates to false with message "expected message, received message"
      And given a matching should_not pattern,
        Evaluates to true.
      And given a non-matching should_not pattern,
        Evaluates to false with message "expected message matching, received message"
    When given a matcher that evaluates to false,
      Evaluates to false with message "expected to match".
  SCENARIOS

  let(:matcher) { example_group.be_truthy }

  describe 'error message for should not' do
    let(:invalid_message) { "failure: testing negative condition with positive matcher\n~>  use the :fail_with_actual matcher instead" }

    it { expect(instance.failure_message_when_negated).to be == invalid_message }
  end # context

  describe 'with a passing matcher' do
    let(:actual) { true }

    it { expect(instance.matches? matcher).to be true }

    describe 'with a correct should_not message' do
      let(:correct_message) { "expected: falsey value\n     got: true" }
      let(:instance)        { super().with_message(correct_message) }

      it { expect(instance.matches? matcher).to be true }
    end # describe

    describe 'with an incorrect should_not message' do
      let(:incorrect_message) { "my hovercraft is full of eels" }
      let(:correct_message)   { "expected: falsey value\n     got: true" }
      let(:failure_message) do
        "expected message:\n#{
          incorrect_message.lines.map { |line| "#{" " * 2}#{line}" }.join
        }\nreceived message:\n#{
          correct_message.lines.map   { |line| "#{" " * 2}#{line}" }.join
        }"
      end # let
      let(:instance) { super().with_message(incorrect_message) }

      it { expect(instance.matches? matcher).to be false }
      it 'failure message' do
        instance.matches? matcher
        expect(instance.failure_message).to eq failure_message
      end # it
    end # describe

    describe 'with a matching should_not pattern' do
      let(:correct_message) { /falsey value/i }
      let(:instance)        { super().with_message(correct_message) }

      it { expect(instance.matches? matcher).to be true }
    end # describe

    describe 'with a non-matching should_not pattern' do
      let(:incorrect_message) { /hovercraft is full of eels/ }
      let(:correct_message)   { "expected: falsey value\n     got: true" }
      let(:failure_message) do
        "expected message matching:\n#{
          incorrect_message.inspect.lines.map { |line| "#{" " * 2}#{line}" }.join
        }\nreceived message:\n#{
          correct_message.lines.map   { |line| "#{" " * 2}#{line}" }.join
        }"
      end # let
      let(:instance) { super().with_message(incorrect_message) }

      it { expect(instance.matches? matcher).to be false }
      it 'failure message' do
        instance.matches? matcher
        expect(instance.failure_message).to eq failure_message
      end # it
    end # describe
  end # describe

  describe 'with a failing matcher' do
    let(:actual) { false }
    let(:received_message) do
      "expected: truthy value\n     got: false".lines.map { |line| "#{" " * 4}#{line}" }.join("\n")
    end # let
    let(:expected_message) do
      "expected #{matcher} to match #{actual}\n  message:\n#{received_message}"      
    end # let

    it { expect(instance.matches? matcher).to be false }
    it 'failure message' do
      instance.matches? matcher
      expect(instance.failure_message).to eq expected_message
    end # it
  end # describe
end # describe
