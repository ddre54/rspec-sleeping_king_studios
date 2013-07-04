# spec/rspec/sleeping_king_studios/matchers/core/have_reader_spec.rb

require 'rspec/sleeping_king_studios/spec_helper'

require 'rspec/sleeping_king_studios/matchers/core/have_reader'

describe '#have_reader' do
  let(:example_group) { RSpec::Core::ExampleGroup.new }
  let(:property)      { :foo }
  let(:instance)      { example_group.have_reader property }

  specify { expect(example_group).to respond_to(:have_reader).with(1).arguments }

  describe '#with' do
    specify { expect(instance).to respond_to(:with).with(1).arguments }
    specify { expect(instance.with 5).to be instance }
  end # describe with

  <<-SCENARIOS
    When the object responds to :property,
      And there is no expected value set,
        Evaluates to true with should_not message "expected not to respond to".
      And there is an expected value set,
        And the expected value matches the actual value,
          Evaluates to true with should_not message "expected not to respond to with value".
        And the expected value does not match the actual value,
          Evaluates to false with should message "unexpected value for, expected, received".
    When the object does not respond to :property,
      Evaluates to false with should message "expected to respond to".
  SCENARIOS

  describe 'with an object responding to :property' do
    let(:actual) { Class.new.tap { |klass| klass.send :define_method, property, -> { 42 } }.new }

    specify 'with no argument set' do
      expect(instance).to pass_with_actual(actual).
        with_message "expected #{actual} not to respond to #{property.inspect}"
    end # specify

    specify 'with a correct argument set' do
      expect(instance.with 42).to pass_with_actual(actual).
        with_message "expected #{actual} not to respond to #{property.inspect} with value 42"
    end # specify

    specify 'with an incorrect argument set' do
      failure_message = "unexpected value for #{actual}\##{property}\n" +
        "  expected: nil\n       got: 42"
      expect(instance.with nil).to fail_with_actual(actual).
        with_message failure_message
    end # specify
  end # describe

  describe 'with an object that does not respond to :property' do
    let(:actual) { Object.new }

    specify do
      expect(instance).to fail_with_actual(actual).
        with_message "expected #{actual} to respond to #{property.inspect}"
    end # specify
  end # describe
end # describe