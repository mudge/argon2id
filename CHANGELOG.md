# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2024-11-02

### Added

- Added support for JRuby 9.4 by adding an implementation of Argon2id hashing
  and verification using JRuby-OpenSSL's Bouncy Castle internals.
- Added `output` to `Argon2id::Password` instances so the actual "output" part
  of a password hash can be retrieved (and compared)

### Changed

- Verifying a password will now consistently raise an `ArgumentError` when
  given an invalid encoded hash rather than an `Argon2id::Error`

## [0.3.0] - 2024-11-01

### Added

- Expose all parameters of a hash through new readers on `Argon2id::Password`:
  namely, `type`, `version`, `m_cost`, `t_cost`, and `parallelism`

### Changed

- Remove the dependency on the `base64` gem by inlining the definition of
  `Base64.decode64` (thanks to @etiennebarrie for the tip)

## [0.2.1] - 2024-11-01

### Added

- Anything that can be coerced to a String can now be passed to
  `Argon2id::Password.new`

## [0.2.0] - 2024-11-01

### Added

- The original salt for an `Argon2id::Password` can now be retrieved with
  `Argon2id::Password#salt`

### Changed

- Encoded hashes are now validated when initialising an `Argon2id::Password`,
  raising an `ArgumentError` if they are invalid

## [0.1.2] - 2024-11-01

### Fixed

- Validate that the encoded hash passed to `Argon2id::Password.new` is a
  null-terminated C string, raising an `ArgumentError` if it contains extra null
  bytes

## [0.1.1] - 2024-11-01

### Added

- RDoc documentation for the API

### Fixed

- Saved a superfluous extra byte when allocating the buffer for the encoded
  hash

## [0.1.0] - 2024-10-31

### Added

- The initial version of the Argon2id gem, providing Ruby bindings to the
  reference C implementation of Argon2, the password-hashing function that won
  the Password Hashing Competition.

[0.4.0]: https://github.com/mudge/argon2id/releases/tag/v0.4.0
[0.3.0]: https://github.com/mudge/argon2id/releases/tag/v0.3.0
[0.2.1]: https://github.com/mudge/argon2id/releases/tag/v0.2.1
[0.2.0]: https://github.com/mudge/argon2id/releases/tag/v0.2.0
[0.1.2]: https://github.com/mudge/argon2id/releases/tag/v0.1.2
[0.1.1]: https://github.com/mudge/argon2id/releases/tag/v0.1.1
[0.1.0]: https://github.com/mudge/argon2id/releases/tag/v0.1.0
