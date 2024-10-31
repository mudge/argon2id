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
      cflags = [ENV["CFLAGS"], "-fPIC"].compact.join(" ")
      env = {
        "PREFIX" => File.expand_path(port_path),
        "LIBRARY_REL" => "lib",
        "CC" => gcc_cmd,
        "CFLAGS" => cflags
      }
      if enable_config("cross-build")
        if host.include?("darwin")
          env["AR"] = "#{host}-libtool"
          env["ARFLAGS"] = "-o"
        else
          env["AR"] = "#{host}-ar"
        end
      end

      execute("compile", make_cmd, env: env)
    end

    def install
      return if installed?

      execute("install", "#{make_cmd} install", env: {
        "PREFIX" => File.expand_path(port_path),
        "LIBRARY_REL" => "lib"
      })
    end
  end

  recipe
end
