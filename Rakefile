require "rake/extensiontask"
require "rake_compiler_dock"
require "minitest/test_task"

CLEAN.add("lib/**/*.{o,so,bundle}", "pkg")

cross_platforms = %w[
  aarch64-linux-gnu
  aarch64-linux-musl
  arm-linux-gnu
  arm-linux-musl
  arm64-darwin
  x64-mingw-ucrt
  x64-mingw32
  x86-linux-gnu
  x86-linux-musl
  x86-mingw32
  x86_64-darwin
  x86_64-linux-gnu
  x86_64-linux-musl
].freeze

ENV["RUBY_CC_VERSION"] = %w[3.4.0 3.3.5 3.2.0 3.1.0].join(":")

gemspec = Gem::Specification.load("argon2id.gemspec")

Gem::PackageTask.new(gemspec).define

namespace :java do
  java_gemspec = gemspec.dup
  java_gemspec.files.reject! { |path| File.fnmatch?("ext/*", path) }
  java_gemspec.extensions.clear
  java_gemspec.platform = Gem::Platform.new("java")
  java_gemspec.required_ruby_version = ">= 3.1.0"

  Gem::PackageTask.new(java_gemspec).define
end

Rake::ExtensionTask.new("argon2id", gemspec) do |e|
  e.lib_dir = "lib/argon2id"
  e.cross_compile = true
  e.cross_platform = cross_platforms
end

Minitest::TestTask.create

begin
  require "ruby_memcheck"

  namespace :test do
    RubyMemcheck::TestTask.new(valgrind: :compile)
  end
rescue LoadError
  # Only define the test:valgrind task if ruby_memcheck is installed
end

namespace :gem do
  cross_platforms.each do |platform|
    desc "Compile and build native gem for #{platform}"
    task platform do
      RakeCompilerDock.sh <<~SCRIPT, platform: platform, verbose: true
        gem install bundler --no-document &&
        bundle &&
        bundle exec rake native:#{platform} pkg/#{gemspec.full_name}-#{Gem::Platform.new(platform)}.gem PATH="/usr/local/bin:$PATH"
      SCRIPT
    end
  end
end

task default: [:compile, :test]
