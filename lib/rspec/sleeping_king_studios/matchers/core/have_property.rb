# lib/rspec/sleeping_king_studios/matchers/core/have_property.rb

require 'rspec/sleeping_king_studios/matchers/base_matcher'
require 'rspec/sleeping_king_studios/matchers/core/require'

module RSpec::SleepingKingStudios::Matchers::Core
  # Matcher for testing whether an object has a specific property, e.g.
  # responds to :property and :property= and :property= updates the value of
  # :property.
  # 
  # @since 1.0.0
  class HavePropertyMatcher < RSpec::SleepingKingStudios::Matchers::BaseMatcher
    # @param [String, Symbol] expected the property to check for on the actual
    #   object
    def initialize expected
      super
      @expected = expected.intern
    end # method initialize

    # Checks if the object responds to :expected and :expected=. Additionally,
    # if a value expectation is set, assigns the value via :expected= and
    # compares the subsequent value of :expected to the specified value.
    # 
    # @param [Object] actual the object to check
    # 
    # @return [Boolean] true if the object responds to :expected and
    #   :expected= and matches the value expectation (if any); otherwise false
    def matches? actual
      super

      @match_reader = @actual.respond_to? @expected
      @match_writer = @actual.respond_to? :"#{@expected}="
      
      return false unless @match_reader && @match_writer

      if @value_set
        @actual.send :"#{@expected}=", @value
        return false unless @actual.send(@expected) == @value
      end # if
      
      true
    end # method matches?

    # Sets a value expectation. The matcher will set the object's value to the
    # specified value using :property=, then compare the value from :property
    # with the specified value.
    # 
    # @param [Object] value the value to set and then compare
    # 
    # @return [HavePropertyMatcher] self
    def with value
      @value = value
      @value_set = true
      self
    end # method with

    # @see BaseMatcher#failure_message_for_should
    def failure_message_for_should
      methods = []
      methods << ":#{@expected}"  unless @match_reader
      methods << ":#{@expected}=" unless @match_writer

      return "expected #{@actual.inspect} to respond to #{methods.join " and "}" unless methods.empty?

      "unexpected value for #{@actual.inspect}\##{@expected}" +
        "\n  expected: #{@value.inspect}" +
        "\n       got: #{@actual.send(@expected).inspect}"
    end # failure_message_for_should

    # @see BaseMatcher#failure_message_for_should_not
    def failure_message_for_should_not
      message = "expected #{@actual.inspect} not to respond to :#{@expected} or :#{@expected}="
      message << " with value #{@value.inspect}" if @value_set
      message
    end # failure_message_for_should_not
  end # class
end # module

module RSpec::SleepingKingStudios::Matchers
  # @see RSpec::SleepingKingStudios::Matchers::Core::HavePropertyMatcher#matches?
  def have_property expected
    RSpec::SleepingKingStudios::Matchers::Core::HavePropertyMatcher.new expected
  end # method have_property
end # module
