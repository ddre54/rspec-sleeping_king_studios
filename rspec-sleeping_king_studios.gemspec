# rspec-sleeping_king_studios.gemspec

$: << './lib'
require 'rspec/sleeping_king_studios/version'

Gem::Specification.new do |gem|
  gem.name        = 'rspec-sleeping_king_studios'
  gem.version     = RSpec::SleepingKingStudios::VERSION
  gem.date        = Time.now.utc.strftime "%Y-%m-%d"
  gem.summary     = 'A collection of RSpec patches and custom matchers.'
  gem.description = <<-DESCRIPTION
    A collection of RSpec patches and custom matchers. The features can be
    included individually or by category. For more information, check out the
    README.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir["lib/**/*.rb", "LICENSE", "*.md"]

  gem.add_runtime_dependency 'rspec',                       '~> 3.0'
  gem.add_runtime_dependency 'sleeping_king_studios-tools', '0.2.0.beta.0'

  gem.add_development_dependency 'appraisal',    '~> 1.0', '>= 1.0.3'
  gem.add_development_dependency 'byebug',       '~> 3.5', '>= 3.5.1'
  gem.add_development_dependency 'factory_girl', '~> 4.2'
  gem.add_development_dependency 'rake',         '~> 10.3'

  gem.add_development_dependency 'aruba',        '~> 0.9'
  gem.add_development_dependency 'cucumber',     '~> 1.3', '>= 1.3.19'

  gem.add_development_dependency 'activemodel',  '>= 3.0', '< 5.0'
end # gemspec
