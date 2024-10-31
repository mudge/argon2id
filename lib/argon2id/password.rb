# frozen_string_literal: true

require "openssl"

module Argon2id
  class Password
    attr_reader :encoded

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

    def initialize(encoded)
      @encoded = encoded
    end

    def to_s
      encoded
    end

    def ==(other)
      Argon2id.verify(encoded, String(other))
    end

    alias_method :is_password?, :==
  end
end
