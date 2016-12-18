# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pecorb/version'

Gem::Specification.new do |spec|
  spec.name          = "pecorb"
  spec.version       = Pecorb::VERSION
  spec.authors       = ["Steven Occhipinti"]
  spec.email         = ["dev@stevenocchipinti.com"]

  spec.summary       = "A lightweight, ruby version of peco with filtering"
  spec.description   = "A lightweight, ruby version of peco with filtering"
  spec.homepage      = "https://github.com/stevenocchipinti/pecorb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "pry-byebug"
end
