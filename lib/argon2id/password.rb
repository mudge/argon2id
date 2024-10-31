# frozen_string_literal: true

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
    attr_reader :encoded

    # Create a new Password object that hashes a given plain text password.
    #
    # - +:t_cost+: integer (default 2) the "time cost" given as a number of iterations
    # - +:m_cost+: integer (default 19456) the "memory cost" given in kibibytes
    # - +:parallelism+: integer (default 1) the number of threads and compute lanes to use
    # - +:salt_len+: integer (default 16) the salt size in bytes
    # - +:output_len+: integer (default 32) the desired length of the hash in bytes
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
    def initialize(encoded)
      @encoded = encoded
    end

    # Return the encoded password hash.
    def to_s
      encoded
    end

    # Compare the password with given plain text, returning true if it verifies
    # successfully.
    def ==(other)
      Argon2id.verify(encoded, String(other))
    end

    alias_method :is_password?, :==
  end
end
