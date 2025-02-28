# frozen_string_literal: true

require_relative "lib/cdss/version"

Gem::Specification.new do |spec|
  spec.name = "cdss-ruby"
  spec.version = Cdss::VERSION
  spec.authors = ["Matt Michnal "]
  spec.email = ["mattm3646@gmail.com"]
  spec.summary = "Ruby wrapper for various water resource APIs"
  spec.description = "Access water station data from USGS, Colorado DWR, TWDB, and other water agencies"
  spec.homepage = "https://github.com/mgm702/cdss-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/mgm702/cdss-ruby",
    "changelog_uri" => "https://github.com/mgm702/cdss-ruby/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://github.com/mgm702/cdss-ruby/blob/main/README.md",
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-configurable", "~> 1.0"
  spec.add_dependency "httparty", "~> 0.21.0"
  spec.add_dependency "zeitwerk", "~> 2.6"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.5"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "vcr", "~> 6.0"
  spec.add_development_dependency "webmock", "~> 3.18"
end
