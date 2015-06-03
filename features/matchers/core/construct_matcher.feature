# features/matchers/core/construct_matcher.feature

Feature: `construct` matcher
  Use the `construct` matcher to specify details of an object's constructor. In
  its most basic form, it specifies that the given object responds to `::new`:

  ```ruby
  expect(my_class).to construct
  ```

  The `construct` matcher is also aliased as `be_constructible`

  As per the `respond_to` matcher, you can specify an expected number or range
  of arguments and/or a list of keywords, which will be matched against an
  allocated instance's `#initialize` method. The matcher will pass if and only
  if the instance can be initialized with the specified arguments and keywords.

  ```ruby
  expect(my_class).to construct.with(2).arguments

  expect(my_class).to construct.with(1..3).arguments

  expect(my_class).to construct.with_unlimited_arguments

  expect(my_class).to construct.with_keywords(:foo, :bar, :baz)

  expect(my_class).to construct.with(1..3).arguments.and_keywords(:foo, :bar, :baz)

  expect(my_class).to construct.with_arbitrary_keywords
  ```

  Scenario: basic usage
    Given a file named "construct_matcher_spec.rb" with:
      """ruby
        require 'rspec/sleeping_king_studios/matchers/core/construct'

        class MyClass
          def initialize(foo, bar = nil, baz = nil, wibble: 'wibble', wobble: 'wobble')

          end # constructor
        end # class

        RSpec.describe String do
          # Passing expectations.
          it { expect('a String').not_to construct }
          it { expect('a String').not_to be_constructible }

          # Failing expectations.
          it { expect('a String').to construct }
          it { expect('a String').to be_constructible }
        end # describe

        RSpec.describe StandardError do
          # Passing expectations.
          it { expect(StandardError).to construct }
          it { expect(StandardError).to be_constructible }
          it { expect(StandardError).to construct.with(1).argument }
          it { expect(StandardError).to construct.with(0..1).arguments }

          # Failing expectations.
          it { expect(StandardError).not_to construct }
          it { expect(StandardError).not_to be_constructible }
          it { expect(StandardError).not_to construct.with(1).argument }
          it { expect(StandardError).not_to construct.with(0..1).arguments }
        end # describe

        RSpec.describe MyClass do
          # Passing expectations.
          it { expect(described_class).to construct }
          it { expect(described_class).not_to construct.with(0).arguments }
          it { expect(described_class).to construct.with(2).arguments }
          it { expect(described_class).not_to construct.with(0..4).arguments }
          it { expect(described_class).to construct.with(1..3).arguments }
          it { expect(described_class).to construct.with(1..3, :wibble, :wobble) }
          it { expect(described_class).not_to construct.with(1..3, :foo, :bar) }

          # Failing expectations.
          it { expect(described_class).not_to construct }
          it { expect(described_class).to construct.with(0).arguments }
          it { expect(described_class).not_to construct.with(2).arguments }
          it { expect(described_class).to construct.with(0..4).arguments }
          it { expect(described_class).not_to construct.with(1..3).arguments }
          it { expect(described_class).not_to construct.with(1..3, :wibble, :wobble) }
          it { expect(described_class).to construct.with(1..3, :foo, :bar) }
        end # describe
      """
    When I run `rspec construct_matcher_spec.rb`
    Then the output should contain "26 examples, 13 failures"
    Then the output should contain:
      """
           Failure/Error: it { expect('a String').to construct }
             expected "a String" to be constructible
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(StandardError).not_to construct }
             expected StandardError not to be constructible
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(StandardError).not_to construct.with(1).argument }
             expected StandardError not to be constructible with 1 argument
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(StandardError).not_to construct.with(0..1).arguments }
             expected StandardError not to be constructible with 0..1 arguments
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).not_to construct }
             expected MyClass not to be constructible
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).to construct.with(0).arguments }
             expected MyClass to be constructible with arguments:
               expected at least 1 arguments, but received 0
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).not_to construct.with(2).arguments }
             expected MyClass not to be constructible with 2 arguments
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).to construct.with(0..4).arguments }
             expected MyClass to be constructible with arguments:
               expected at least 1 arguments, but received 0
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).not_to construct.with(1..3).arguments }
             expected MyClass not to be constructible with 1..3 arguments
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).not_to construct.with(1..3, :wibble, :wobble) }
             expected MyClass not to be constructible with 1..3 arguments and keywords :wibble and :wobble
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).to construct.with(1..3, :foo, :bar) }
             expected MyClass to be constructible with arguments:
               unexpected keywords :foo and :bar
      """

  Scenario: specifying required keywords
    Given Ruby 2.2 or greater
    Given a file named "construct_matcher_spec.rb" with:
      """ruby
        require 'rspec/sleeping_king_studios/matchers/core/construct'

        class MyClass
          def initialize(foo, bar = nil, baz = nil, wibble: 'wibble', wobble: 'wobble', greetings:)

          end # constructor
        end # class

        RSpec.describe MyClass do
          # Passing expectations.
          it { expect(described_class).not_to construct.with(1..3, :wibble, :wobble) }
          it { expect(described_class).to construct.with(1..3, :wibble, :wobble, :greetings) }

          # Failing expectations.
          it { expect(described_class).to construct.with(1..3, :wibble, :wobble) }
          it { expect(described_class).not_to construct.with(1..3, :wibble, :wobble, :greetings) }
        end # describe
      """
    When I run `rspec construct_matcher_spec.rb`
    Then the output should contain "4 examples, 2 failures"
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).to construct.with(1..3, :wibble, :wobble) }
             expected MyClass to be constructible with arguments:
               missing keyword :greetings
      """
    Then the output should contain:
      """
           Failure/Error: it { expect(described_class).not_to construct.with(1..3, :wibble, :wobble, :greetings) }
             expected MyClass not to be constructible with 1..3 arguments and keywords :wibble, :wobble, and :greetings
      """
