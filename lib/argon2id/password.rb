# frozen_string_literal: true

require "base64"
require "openssl"

module Argon2id
  # The Password class encapsulates an encoded Argon2id password hash.
  #
  # To hash a plain text password, use Argon2id::Password.create:
  #
  #   password = Argon2id::Password.create("password")
  #   password.to_s
  #   #=> "$argon2id$v=19$m=19456,t=2,p=1$+Lrjry9Ifq0poLr15OGU1Q$utkDvejJB0ugwm4s9+a+vF6+1a/W+Y3CYa5Wte/85ig"
  #
  # To verify an encoded Argon2id password hash, use Argon2id::Password.new:
  #
  #   password = Argon2id::Password.new("$argon2id$v=19$m=19456,t=2,p=1$+Lrjry9Ifq0poLr15OGU1Q$utkDvejJB0ugwm4s9+a+vF6+1a/W+Y3CYa5Wte/85ig")
  #   password == "password"
  #   #=> true
  class Password
    # A regular expression to match valid hashes.
    PATTERN = %r{
      \A
      \$
      argon2(?:id|i|d)
      (?:\$v=\d+)?
      \$m=\d+
      ,t=\d+
      ,p=\d+
      \$
      (?<base64_salt>[a-zA-Z0-9+/]+)
      \$
      [a-zA-Z0-9+/]+
      \z
    }x.freeze

    # The encoded password hash.
    attr_reader :encoded

    # The salt.
    attr_reader :salt

    # Create a new Password object that hashes a given plain text password +pwd+.
    #
    # - +:t_cost+: integer (default 2) the "time cost" given as a number of iterations
    # - +:m_cost+: integer (default 19456) the "memory cost" given in kibibytes
    # - +:parallelism+: integer (default 1) the number of threads and compute lanes to use
    # - +:salt_len+: integer (default 16) the salt size in bytes
    # - +:output_len+: integer (default 32) the desired length of the hash in bytes
    #
    # For example, with the default configuration:
    #
    #   password = Argon2id::Password.create("password")
    #   password.to_s
    #   #=> "$argon2id$v=19$m=19456,t=2,p=1$FI8yp1gXbthJCskBlpKPoQ$nOfCCpS2r+I8GRN71cZND4cskn7YKBNzuHUEO3YpY2s"
    #
    # When overriding the configuration:
    #
    #   password = Argon2id::Password.create("password", t_cost: 3, m_cost: 12288)
    #   password.to_s
    #   #=> "$argon2id$v=19$m=12288,t=3,p=1$JigW7fFn+N3NImt+aWpuzw$eM5F1cKeIBALNTU6LuWra75Zi2nymGvQLWzJzVFv0Nc"
    def self.create(pwd, t_cost: Argon2id.t_cost, m_cost: Argon2id.m_cost, parallelism: Argon2id.parallelism, salt_len: Argon2id.salt_len, output_len: Argon2id.output_len)
      new(
        Argon2id.hash_encoded(
          Integer(t_cost),
          Integer(m_cost),
          Integer(parallelism),
          String(pwd),
          OpenSSL::Random.random_bytes(Integer(salt_len)),
          Integer(output_len)
        )
      )
    end

    # call-seq: Argon2id::Password.new(encoded)
    #
    # Create a new Password with the given encoded password hash.
    #
    #   password = Argon2id::Password.new("$argon2id$v=19$m=19456,t=2,p=1$FI8yp1gXbthJCskBlpKPoQ$nOfCCpS2r+I8GRN71cZND4cskn7YKBNzuHUEO3YpY2s")
    #
    # Raises an ArgumentError if given an invalid hash.
    def initialize(encoded)
      raise ArgumentError, "invalid hash" unless PATTERN =~ String(encoded)

      @encoded = Regexp.last_match(0)
      @salt = Base64.decode64(Regexp.last_match(1))
    end

    # Return the encoded password hash.
    def to_s
      encoded
    end

    # Compare the password with given plain text, returning true if it verifies
    # successfully.
    #
    #   password = Argon2id::Password.new("$argon2id$v=19$m=19456,t=2,p=1$FI8yp1gXbthJCskBlpKPoQ$nOfCCpS2r+I8GRN71cZND4cskn7YKBNzuHUEO3YpY2s")
    #   password == "password"    #=> true
    #   password == "notpassword" #=> false
    def ==(other)
      Argon2id.verify(encoded, String(other))
    end

    alias_method :is_password?, :==
  end
end
