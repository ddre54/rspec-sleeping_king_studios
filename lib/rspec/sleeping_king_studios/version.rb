# lib/rspec/sleeping_king_studios/version.rb

module RSpec
  module SleepingKingStudios
    # @api private
    #
    # The current version of the gem.
    #
    # @see http://semver.org/
    module Version
      # Major version.
      MAJOR = 2
      # Minor version.
      MINOR = 4
      # Patch version.
      PATCH = 0
      # Prerelease version.
      PRERELEASE = :rc
      # Build metadata.
      BUILD = 0

      # Generates the gem version string from the Version constants.
      #
      # Inlined here because dependencies may not be loaded when processing a
      # gemspec, which results in the user being unable to install the gem for
      # the first time.
      #
      # @see SleepingKingStudios::Tools::SemanticVersion#to_gem_version
      def self.to_gem_version
        str = "#{MAJOR}.#{MINOR}.#{PATCH}"

        prerelease = self.const_defined?(:PRERELEASE) ? PRERELEASE : nil
        str << ".#{prerelease}" unless prerelease.nil? || (prerelease.respond_to?(:empty?) && prerelease.empty?)

        build = self.const_defined?(:BUILD) ? BUILD : nil
        str << ".#{build}" unless build.nil? || (build.respond_to?(:empty?) && build.empty?)

        str
      end # class method to_version
    end # module

    VERSION = Version.to_gem_version
  end # module
end # module
