# lib/rspec/sleeping_king_studios/examples/property_examples/predicates.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'
require 'rspec/sleeping_king_studios/examples/property_examples'
require 'rspec/sleeping_king_studios/matchers/core/have_predicate'

module RSpec::SleepingKingStudios::Examples
  module PropertyExamples
    module Predicates
      extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

      shared_examples 'should have predicate' do |property_name, expected_value = UNDEFINED_VALUE_EXPECTATION|
        property_name = property_name.to_s.sub(/\?\z/, '')

        it "should have predicate :#{property_name}?" do
          object = defined?(instance) ? instance : subject

          if expected_value == UNDEFINED_VALUE_EXPECTATION
            expect(object).to have_predicate(property_name)
          else
            expected_value = format_expected_value(expected_value)

            expect(object).to have_predicate(property_name).with_value(expected_value)
          end # if-else
        end # it
      end # shared_examples
      alias_shared_examples 'defines predicate', 'should have predicate'
      alias_shared_examples 'has predicate', 'should have predicate'
      alias_shared_examples 'should define predicate', 'should have predicate'
    end # module
  end # module
end # module
