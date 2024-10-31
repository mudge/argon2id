# frozen_string_literal: true

require "mkmf"

$CFLAGS << " -Wextra"

$VPATH << "$(srcdir)/libargon2"
$VPATH << "$(srcdir)/libargon2/blake2"

$srcs = Dir.glob("#{$srcdir}/{,libargon2/,libargon2/blake2/}*.c").map { |n| File.basename(n) }.sort

$CPPFLAGS << " " << "-I$(srcdir)/libargon2"

have_header("stdint.h")
have_header("argon2.h")

create_makefile "argon2id"
