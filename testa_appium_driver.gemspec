# frozen_string_literal: true

require_relative "lib/testa_appium_driver/version"

Gem::Specification.new do |spec|
  spec.name = "testa_appium_driver"
  spec.version = TestaAppiumDriver::VERSION
  spec.authors = ["karlo.razumovic"]
  spec.email = ["karlo.razumovic@gmail.com"]

  spec.summary = "Appium made easy"
  spec.description = "Testa appium driver is a wrapper around ruby_lib_core. It significantly reduces the amount of code need to achieve your goals."
  spec.homepage = "https://github.com/Karazum/testa_appium_driver"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  #spec.metadata["allowed_push_host"] = "Set to 'https://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Karazum/testa_appium_driver"
  spec.metadata["changelog_uri"] = "https://github.com/Karazum/testa_appium_driver"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "appium_lib_core", ["= 4.7.0"]
  spec.add_runtime_dependency "json", ["= 2.1.0"]

  spec.add_development_dependency "rubocop", ["= 1.19.0"]
  spec.add_development_dependency "rake", ["~> 13.0"]

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
