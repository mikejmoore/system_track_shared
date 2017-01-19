#gem build system_track_shared.gemspec
#gem inabox ./system-track-shared-1.5.gem -g http://gemserver.openlogic.local:10080

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'system_track_shared/version'

Gem::Specification.new do |spec|
  spec.name          = "system-track-shared"
  spec.version       = SystemTrack::VERSION
  spec.authors       = ["Mike Moore"]
  spec.email         = ["m.moore.denver@gmail.com"]

  spec.summary       = "System Track files shared among all services"
  spec.description   = "System Track files shared among all services"
  spec.homepage      = 'https://github.com/mikejmoore/system_track_shared'
  spec.license       = "MIT"

  spec.files = Dir.glob("{bin,lib}/**/*")
  spec.files <<    "lib/system_track_shared.rb"  
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "lib/system_track_shared.rb"]

  spec.add_runtime_dependency 'faraday'
end

# Gem::Specification.new do |gem|
#   gem.authors       = ['Mike Moore / Rogue Wave Software']
#   gem.email         = 'mike.moore@roguewave.com'
#   gem.description   = 'API for creating container clusters and services using Docker Swarm.  Includes service, node, task management'
#   gem.summary       = 'Ruby API for Docker Swarm'
#   gem.homepage      = 'https://github.com/mikejmoore/docker-swarm-api'
#   gem.license       = 'MIT'
#   gem.files         = `git ls-files lib README.md LICENSE`.split($\)
#   gem.name          = 'docker-swarm-api'
#   gem.version       = Docker::Swarm::VERSION
#   gem.add_dependency 'json'
#   gem.add_runtime_dependency 'docker-api', '>= 1.33.1'
#   gem.add_runtime_dependency 'retry_block', '>= 1.2.0'
#   gem.add_development_dependency 'byebug', '~> 6.0'
#   gem.add_development_dependency 'rake', '~> 12.0'
#   gem.add_development_dependency 'rspec', '~> 3.0'
#   gem.add_development_dependency 'rspec-its', '1.2'
#   gem.add_development_dependency 'pry', '~> 0.10.4'
#   gem.add_development_dependency 'single_cov', '~> 0.5.8'
#   gem.add_development_dependency 'parallel', '~> 1.10'
# end
