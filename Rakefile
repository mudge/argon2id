require "rake/extensiontask"
require "rake_compiler_dock"
require "rake/testtask"

CLEAN.add("lib/**/*.{o,so,bundle}", "pkg")

cross_platforms = %w[
  aarch64-linux
  arm-linux
  arm64-darwin
  x64-mingw-ucrt
  x64-mingw32
  x86-linux
  x86-mingw32
  x86_64-darwin
  x86_64-linux
].freeze

ENV["RUBY_CC_VERSION"] = %w[3.3.0 3.2.0 3.1.0 3.0.0 2.7.0 2.6.0].join(":")

gemspec = Gem::Specification.load("argon2id.gemspec")

Gem::PackageTask.new(gemspec).define

Rake::ExtensionTask.new("argon2id", gemspec) do |e|
  e.cross_compile = true
  e.cross_platform = cross_platforms
end

Rake::TestTask.new do |t|
  t.warning = true
end

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
