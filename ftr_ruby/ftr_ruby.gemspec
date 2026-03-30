# frozen_string_literal: true

# frozen_string_literal: true

# Robust way to load the version file during gem build
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ftr_ruby/version"
# ... rest of your spec unchanged ...
Gem::Specification.new do |spec|
  spec.name = "ftr_ruby"
  spec.version = FtrRuby::VERSION
  spec.authors = ["markwilkinson"]
  spec.email = ["mark.wilkinson@upm.es"]

  spec.summary = "Libraries supporting the FTR Vocabulary."
  spec.description = "Libraries supporting the FAIR Testing Resources Vocabulary - Tests and test outputs."
  spec.homepage = "https://github.com/markwilkinson/FTR-Ruby/tree/master"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/markwilkinson/FTR-Ruby/tree/master"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/ftr_ruby"
  spec.metadata["bug_tracker_uri"] = "https://github.com/markwilkinson/FTR-Ruby/issues"
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
