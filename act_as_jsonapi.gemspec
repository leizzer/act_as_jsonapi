# frozen_string_literal: true

require_relative "lib/act_as_jsonapi/version"

Gem::Specification.new do |spec|
  spec.name          = "act_as_jsonapi"
  spec.version       = ActAsJsonapi::VERSION
  spec.authors       = ["leizzer"]

  spec.summary       = "Light weight gem on top of `jsonapi_serializer` and `pundit` to keep controllers DRY"
  spec.description   = "Act as JSONAPI is a small and flexible gem on top of `jsonapi_serializer`. \
  By including Act as JSONAPI in your controllers you instantly \
  get all basic controller actions for the model. You can override the model and serializer if \
  the name of the controller doesn't match the model. \
  The json formatter and errors can be used separatly."
  spec.homepage      = "https://github.com/leizzer/act_as_jsonapi"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/leizzer/act_as_jsonapi"
  spec.metadata["changelog_uri"] = "https://github.com/leizzer/act_as_jsonapi/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.add_development_dependency "rubocop", "~> 1.7"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"

  spec.add_dependency "jsonapi-serializer", "~> 2.2.0"
  spec.add_dependency "activesupport", "~> 7.0"
  spec.add_dependency "pundit", "~> 2.1"
end
