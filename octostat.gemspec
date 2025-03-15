lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "octostat/version"

Gem::Specification.new do |spec|
  spec.name          = "Octostat"
  spec.version       = Octostat::VERSION
  spec.authors       = ["Joé Dupuis"]
  spec.email         = ["joe@dupuis.io"]

  spec.summary       = "Octostat extract git information to Sqlite"
  spec.homepage      = "https://github.com/testdouble/octostat"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/testdouble/octostat/main/CHANGELOG.md"

  spec.files = Dir['lib/**/*.rb', 'Rakefile', 'README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
