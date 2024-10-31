# frozen_string_literal: true

def libargon2_recipe
  gem "mini_portile2", "2.8.7"
  require "mini_portile2"

  recipe = MiniPortile.new("libargon2", "20190702")
  recipe.files = [{
    url: "https://github.com/P-H-C/phc-winner-argon2/archive/refs/tags/20190702.tar.gz",
    sha256: "daf972a89577f8772602bf2eb38b6a3dd3d922bf5724d45e7f9589b5e830442c"
  }]

  # Re-open MiniPortile as libargon2 only uses make and has no configure step
  class << recipe
    def configured?
      true
    end

    def compile
      # libargon2's Makefile shells out to uname to determine the host platform
      # which doesn't work when cross-compiling. Instead, we manually compile
      # the necessary source files and generate only the static library in the
      # hopes that it is compatible across the most platforms.
      cflags = [ENV["CFLAGS"], "-std=c89", "-O3", "-Wall", "-g", "-Iinclude", "-Isrc", "-fPIC", "-pthread"].compact.join(" ")
      objs = %w[argon2 core blake2/blake2b thread encoding ref]
      objs.each do |obj|
        execute("compile-#{File.basename(obj)}", "#{gcc_cmd} #{cflags} -c -o src/#{obj}.o src/#{obj}.c")
      end

      ar_cmd = ENV["AR"] || "ar"
      arflags = ENV["ARFLAGS"] || "rcs"

      # Thanks to @flavorjones for this, see
      # https://github.com/sparklemotion/nokogiri/blob/e05b9949b794ca94b37a90f2fb2555d99a37daa5/ext/nokogiri/extconf.rb#L1074-L1127
      if enable_config("cross-build")
        case host
        when /darwin/
          ar_cmd = "#{host}-libtool"
          arflags = "-o"
        when "i686-redhat-linux"
          ar_cmd = "i686-redhat-linux-gnu-ar"
        when "x86_64-redhat-linux"
          ar_cmd = "x86_64-redhat-linux-gnu-ar"
        else
          ar_cmd = "#{host}-ar"
        end
      end

      execute("archive", "#{ar_cmd} #{arflags} libargon2.a #{objs.map { |obj| "src/#{obj}.o" }.join(" ")}")
    end

    def install
      return if installed?

      lib_dir = File.join(port_path, "lib")
      include_dir = File.join(port_path, "include")
      FileUtils.mkdir_p([lib_dir, include_dir])
      FileUtils.cp(File.join(work_path, "libargon2.a"), lib_dir)
      FileUtils.cp(File.join(work_path, "include", "argon2.h"), include_dir)
    end
  end

  recipe
end
