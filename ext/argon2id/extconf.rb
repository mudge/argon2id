# frozen_string_literal: true

require "mkmf"

require_relative "recipe"

# Configure cross-compiler
RbConfig::CONFIG["CC"] = RbConfig::MAKEFILE_CONFIG["CC"] = ENV["CC"] if ENV["CC"]
$CFLAGS << " -Wextra"

have_header("stdint.h")

recipe = libargon2_recipe
recipe.cook

# Statically link libargon2 into the extension.
$libs << " " << File.join(recipe.lib_path, "libargon2.a").shellescape
$INCFLAGS = ["-I#{recipe.include_path}", $INCFLAGS].join(" ").strip

have_header("argon2.h")

create_makefile "argon2id"
