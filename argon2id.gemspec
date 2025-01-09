# frozen_string_literal: true

require_relative "lib/argon2id/version"

Gem::Specification.new do |s|
  s.name = "argon2id"
  s.version = Argon2id::VERSION
  s.summary = "Ruby bindings to Argon2"
  s.description = "Ruby bindings to Argon2, the password-hashing function that won the 2015 Password Hashing Competition."
  s.license = "BSD-3-Clause"
  s.authors = ["Paul Mucur"]
  s.homepage = "https://github.com/mudge/argon2id"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/mudge/argon2id/issues",
    "changelog_uri" => "https://github.com/mudge/argon2id/blob/main/CHANGELOG.md",
    "funding_uri" => "https://github.com/sponsors/mudge",
    "homepage_uri" => "https://github.com/mudge/argon2id",
    "source_code_uri" => "https://github.com/mudge/argon2id",
    "rubygems_mfa_required" => "true"
  }
  s.required_ruby_version = ">= 2.6.0"
  s.extensions = ["ext/argon2id/extconf.rb"]
  s.files = [
    "CHANGELOG.md",
    "Gemfile",
    "LICENSE",
    "README.md",
    "Rakefile",
    "argon2id.gemspec",
    "ext/argon2id/argon2id.c",
    "ext/argon2id/extconf.rb",
    "ext/argon2id/libargon2/LICENSE",
    "ext/argon2id/libargon2/argon2.c",
    "ext/argon2id/libargon2/argon2.h",
    "ext/argon2id/libargon2/blake2/blake2-impl.h",
    "ext/argon2id/libargon2/blake2/blake2.h",
    "ext/argon2id/libargon2/blake2/blake2b.c",
    "ext/argon2id/libargon2/blake2/blamka-round-opt.h",
    "ext/argon2id/libargon2/blake2/blamka-round-ref.h",
    "ext/argon2id/libargon2/core.c",
    "ext/argon2id/libargon2/core.h",
    "ext/argon2id/libargon2/encoding.c",
    "ext/argon2id/libargon2/encoding.h",
    "ext/argon2id/libargon2/ref.c",
    "ext/argon2id/libargon2/thread.c",
    "ext/argon2id/libargon2/thread.h",
    "lib/argon2id.rb",
    "lib/argon2id/extension.rb",
    "lib/argon2id/password.rb",
    "lib/argon2id/version.rb",
    "test/argon2id/test_password.rb",
    "test/test_argon2id.rb"
  ]
  s.rdoc_options = ["--main", "README.md"]

  s.add_development_dependency("rake-compiler", "~> 1.2")
  s.add_development_dependency("rake-compiler-dock", "~> 1.8")
  s.add_development_dependency("minitest", "~> 5.25")
end
