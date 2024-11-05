# Argon2id - Ruby bindings to the OWASP recommended password-hashing function

Ruby bindings to [Argon2][], the password-hashing function that won the 2015
[Password Hashing Competition][].

[![Build Status](https://github.com/mudge/argon2id/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/mudge/argon2id/actions)

**Current version:** 0.6.0  
**Bundled Argon2 version:** libargon2.1 (20190702)

```ruby
Argon2id::Password.create("password").to_s
#=> "$argon2id$v=19$m=19456,t=2,p=1$agNV6OfDL1OwE44WdrFCJw$ITrBwvCsW4b5GjgZuL67RCcvVMEWBWXtASc9TVyI3rY"

password = Argon2id::Password.new("$argon2id$v=19$m=19456,t=2,p=1$ZS2nBFWBpnt28HjtzNOW4w$SQ+p+dIcWbpzWpZQ/ZZFj8IQkyhYZf127U4QdkRmKFU")
password == "password"     #=> true
password == "not password" #=> false

password.m_cost #=> 19456
password.salt   #=> "e-\xA7\x04U\x81\xA6{v\xF0x\xED\xCC\xD3\x96\xE3"
```

## Table of contents

* [Why Argon2id?](#why-argon2id)
* [Usage](#usage)
    * [Hashing passwords](#hashing-passwords)
    * [Verifying passwords](#verifying-passwords)
    * [Errors](#errors)
* [Requirements](#requirements)
    * [Native gems](#native-gems)
    * [Verifying the gems](#verifying-the-gems)
    * [Installing the `ruby` platform gem](#installing-the-ruby-platform-gem)
* [Thanks](#thanks)
* [Contact](#contact)
* [License](#license)
    * [Dependencies](#dependencies)

## Why Argon2id?

> Argon2 is a password-hashing function that summarizes the state of the art in
> the design of memory-hard functions and can be used to hash passwords for
> credential storage, key derivation, or other applications.
>
> It has a simple design aimed at the highest memory filling rate and effective
> use of multiple computing units, while still providing defense against
> tradeoff attacks (by exploiting the cache and memory organization of the
> recent processors).

— [Argon2][]

> Argon2 was the winner of the 2015 Password Hashing Competition. Out of the
> three Argon2 versions, use the Argon2id variant since it provides a balanced
> approach to resisting both side-channel and GPU-based attacks.

— [OWASP Password Storage Cheat Sheet][]

## Usage

Install argon2id as a dependency:

```ruby
# In your Gemfile
gem "argon2id"

# Or without Bundler
gem install argon2id
```

Include in your code:

```ruby
require "argon2id"
```

### Hashing passwords

Hash a plain text password (e.g. from user input) with
`Argon2id::Password.create`:

```ruby
password = Argon2id::Password.create("opensesame")
```

The encoded value of the resulting hash is available via
`Argon2id::Password#to_s` (ideal for persisting somewhere):

```ruby
password.to_s
#=> "$argon2id$v=19$m=19456,t=2,p=1$ZS2nBFWBpnt28HjtzNOW4w$SQ+p+dIcWbpzWpZQ/ZZFj8IQkyhYZf127U4QdkRmKFU"
```

By default, `Argon2id::Password.create` will use the second set of parameters
recommended by [OWASP][OWASP Password Storage Cheat Sheet] but these can be
overridden by passing keyword arguments to `Argon2id::Password.create`:

* `t_cost`: the "time cost" given as a number of iterations (defaults to 2)
* `m_cost`: the "memory cost" given in kibibytes (defaults to 19 mebibytes)
* `parallelism`: the number of threads and compute lanes to use (defaults to 1)
* `salt_len`: the salt size in bytes (defaults to 16)
* `output_len`: the desired length of the hash in bytes (defaults to 32)

```ruby
password = Argon2id::Password.create("opensesame", t_cost: 3, m_cost: 12288)
password.to_s
#=> "$argon2id$v=19$m=12288,t=3,p=1$uukIsLS6y6etvsgoN20kVg$exMvDX/P9exvEPmnZL2gZClRyMdrnqjqyysLMP/VUWA"
```

If you want to override the parameters for all calls to
`Argon2id::Password.create`, you can set them on `Argon2id` directly:

```ruby
Argon2id.t_cost = 3
Argon2id.m_cost = 12288
Argon2id.parallelism = 1
Argon2id.salt_len = 16
Argon2id.output_len = 32
```

### Verifying passwords

To verify a password against a hash, use `Argon2id::Password#==`:

```ruby
password = Argon2id::Password.create("opensesame")
password == "opensesame"    #=> true
password == "notopensesame" #=> false
```

Or, if you only have the encoded hash (e.g. retrieved from storage):

```ruby
password = Argon2id::Password.new("$argon2id$v=19$m=19456,t=2,p=1$ZS2nBFWBpnt28HjtzNOW4w$SQ+p+dIcWbpzWpZQ/ZZFj8IQkyhYZf127U4QdkRmKFU")
password == "opensesame"    #=> true
password == "notopensesame" #=> false
```

> [!WARNING]
> `Argon2id::Password.new` does not support hashes generated from other Argon2
> variants such as Argon2i and Argon2d.

For compatibility with [bcrypt-ruby][], `Argon2id::Password#==` is aliased to `Argon2id::Password.is_password?`:

```ruby
password = Argon2id::Password.new("$argon2id$v=19$m=19456,t=2,p=1$ZS2nBFWBpnt28HjtzNOW4w$SQ+p+dIcWbpzWpZQ/ZZFj8IQkyhYZf127U4QdkRmKFU")
password.is_password?("opensesame")    #=> true
password.is_password?("notopensesame") #=> false
```

The various parts of the encoded hash can be retrieved:

```ruby
password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")
password.version     #=> 19
password.m_cost      #=> 256
password.t_cost      #=> 2
password.parallelism #=> 1
password.salt        #=> "somesalt"
password.output
#=> "\x9D\xFE\xB9\x10\xE8\v\xAD\x03\x11\xFE\xE2\x0F\x9C\x0E+\x12\xC1y\x87\xB4\xCA\xC9\f.\xF5M[0!\xC6\x8B\xFE"
```

### Errors

Any errors returned from Argon2 will be raised as `Argon2id::Error`, e.g.

```ruby
Argon2id::Password.create("password", salt_len: 0)
# Salt is too short (Argon2id::Error)
```

## Requirements

This gem requires any of the following to run:

* [Ruby](https://www.ruby-lang.org/en/) 2.6 to 3.3
* [JRuby](https://www.jruby.org) 9.4
* [TruffleRuby](https://www.graalvm.org/ruby/) 24.1

> [!NOTE]
> The JRuby version of the gem uses
> [JRuby-OpenSSL](https://github.com/jruby/jruby-openssl)'s implementation of
> Argon2 while the others use the reference C implementation.

### Native gems

Where possible, a pre-compiled native gem will be provided for the following platforms:

* Linux
    * `aarch64-linux` and `arm-linux` (requires [glibc](https://www.gnu.org/software/libc/) 2.29+)
    * `x86-linux` and `x86_64-linux` (requires [glibc](https://www.gnu.org/software/libc/) 2.17+)
    * [musl](https://musl.libc.org/)-based systems such as [Alpine](https://alpinelinux.org) are supported as long as a [glibc-compatible library is installed](https://wiki.alpinelinux.org/wiki/Running_glibc_programs)
* macOS `x86_64-darwin` and `arm64-darwin`
* Windows `x64-mingw32` and `x64-mingw-ucrt`
* Java: any platform running JRuby 9.4 or higher

### Verifying the gems

SHA256 checksums are included in the [release
notes](https://github.com/mudge/argon2id/releases) for each version and can be
checked with `sha256sum`, e.g.

```console
$ gem fetch argon2id -v 0.6.0
Fetching argon2id-0.6.0-arm64-darwin.gem
Downloaded argon2id-0.6.0-arm64-darwin
$ sha256sum argon2id-0.6.0-arm64-darwin.gem
18f1f04be4b5e7badb4d491762e57874febeeb46c64ce1b0a5e3a75b39b5baeb  argon2id-0.6.0-arm64-darwin.gem
```

[GPG](https://www.gnupg.org/) signatures are attached to each release (the
assets ending in `.sig`) and can be verified if you import [our signing key
`0x39AC3530070E0F75`](https://mudge.name/39AC3530070E0F75.asc) (or fetch it
from a public keyserver, e.g. `gpg --keyserver keyserver.ubuntu.com --recv-key
0x39AC3530070E0F75`):

```console
$ gpg --verify argon2id-0.6.0-arm64-darwin.gem.sig argon2id-0.6.0-arm64-darwin.gem
gpg: Signature made Tue  5 Nov 11:30:47 2024 GMT
gpg:                using RSA key 702609D9C790F45B577D7BEC39AC3530070E0F75
gpg: Good signature from "Paul Mucur <mudge@mudge.name>" [unknown]
gpg:                 aka "Paul Mucur <paul@ghostcassette.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 7026 09D9 C790 F45B 577D  7BEC 39AC 3530 070E 0F75
```

The fingerprint should be as shown above or you can independently verify it
with the ones shown in the footer of https://mudge.name.

### Installing the `ruby` platform gem

> [!WARNING]
> We strongly recommend using the native gems where possible to avoid the need
> for compiling the C extension and its dependencies which will take longer and
> be less reliable.

If you wish to compile the gem, you will need to explicitly install the `ruby` platform gem:

```ruby
# In your Gemfile with Bundler 2.3.18+
gem "argon2id", force_ruby_platform: true

# With Bundler 2.1+
bundle config set force_ruby_platform true

# With older versions of Bundler
bundle config force_ruby_platform true

# Without Bundler
gem install argon2id --platform=ruby
```

You will need a full compiler toolchain for compiling Ruby C extensions (see
[Nokogiri's "The Compiler
Toolchain"](https://nokogiri.org/tutorials/installing_nokogiri.html#appendix-a-the-compiler-toolchain))
plus the toolchain required for compiling the vendored version of Argon2.

## Thanks

* Thanks to [Mike Dalessio](https://github.com/flavorjones) for his advice and
 [Ruby C Extensions Explained](https://github.com/flavorjones/ruby-c-extensions-explained)
 project

## Contact

All issues and suggestions should go to [GitHub
Issues](https://github.com/mudge/argon2id/issues).

## License

This library is licensed under the BSD 3-Clause License, see `LICENSE`.

Copyright © 2024, Paul Mucur.

### Dependencies

The source code of [Argon2][] is distributed in the gem. This code is copyright
© 2015 Daniel Dinu, Dmitry Khovratovich (main authors), Jean-Philippe Aumasson
and Samuel Neves, and dual licensed under the [CC0 License][] and the [Apache
2.0 License][].

  [Argon2]: https://github.com/P-H-C/phc-winner-argon2/
  [OWASP Password Storage Cheat Sheet]: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#argon2id
  [bcrypt-ruby]: https://github.com/bcrypt-ruby/bcrypt-ruby
  [CC0 License]: https://creativecommons.org/about/cc0
  [Apache 2.0 License]: https://www.apache.org/licenses/LICENSE-2.0
  [Password Hashing Competition]: https://www.password-hashing.net
