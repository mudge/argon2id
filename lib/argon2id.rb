# frozen_string_literal: true

if RUBY_PLATFORM == "java"
  require "openssl"
else
  begin
    ::RUBY_VERSION =~ /(\d+\.\d+)/
    require_relative "#{Regexp.last_match(1)}/argon2id.so"
  rescue LoadError
    require "argon2id.so"
  end
end

require "argon2id/version"
require "argon2id/password"

module Argon2id
  # The default "time cost" of 2 iterations recommended by OWASP.
  DEFAULT_T_COST = 2

  # The default "memory cost" of 19 mebibytes recommended by OWASP.
  DEFAULT_M_COST = 19_456

  # The default 1 thread and compute lane recommended by OWASP.
  DEFAULT_PARALLELISM = 1

  # The default salt length of 16 bytes.
  DEFAULT_SALT_LEN = 16

  # The default desired hash length of 32 bytes.
  DEFAULT_OUTPUT_LEN = 32

  @t_cost = DEFAULT_T_COST
  @m_cost = DEFAULT_M_COST
  @parallelism = DEFAULT_PARALLELISM
  @salt_len = DEFAULT_SALT_LEN
  @output_len = DEFAULT_OUTPUT_LEN

  class << self
    # The default number of iterations used by Argon2id::Password.create
    attr_accessor :t_cost

    # The default memory cost in kibibytes used by Argon2id::Password.create
    attr_accessor :m_cost

    # The default number of threads and compute lanes used by Argon2id::Password.create
    attr_accessor :parallelism

    # The default salt size in bytes used by Argon2id::Password.create
    attr_accessor :salt_len

    # The default desired length of the hash in bytes used by Argon2id::Password.create
    attr_accessor :output_len
  end

  if RUBY_PLATFORM == "java"
    Error = Class.new(StandardError)

    def self.hash_encoded(t_cost, m_cost, parallelism, pwd, salt, hashlen)
      output = hash_raw(t_cost, m_cost, parallelism, pwd, salt, hashlen)

      encoder = Java::JavaUtil::Base64.get_encoder.without_padding
      encoded_salt = encoder.encode_to_string(salt.to_java_bytes)
      encoded_output = encoder.encode_to_string(output)

      "$argon2id$v=19$m=#{Integer(m_cost)},t=#{Integer(t_cost)}," \
        "p=#{Integer(parallelism)}$#{encoded_salt}$#{encoded_output}"
    end

    def self.verify(encoded, pwd)
      password = Password.new(encoded)
      other_raw = hash_raw(
        password.t_cost,
        password.m_cost,
        password.parallelism,
        String(pwd),
        password.salt,
        password.output.bytesize
      )

      Java::OrgBouncycastleUtil::Arrays.constant_time_are_equal(
        password.output.to_java_bytes,
        other_raw
      )
    end

    def self.hash_raw(t_cost, m_cost, parallelism, pwd, salt, hashlen)
      raise Error, "Salt is too short" if String(salt).empty?

      hash = Java::byte[Integer(hashlen)].new
      params = Java::OrgBouncycastleCryptoParams::Argon2Parameters::Builder
        .new(Java::OrgBouncycastleCryptoParams::Argon2Parameters::ARGON2_id)
        .with_salt(String(salt).to_java_bytes)
        .with_parallelism(Integer(parallelism))
        .with_memory_as_kb(Integer(m_cost))
        .with_iterations(Integer(t_cost))
        .build
      generator = Java::OrgBouncycastleCryptoGenerators::Argon2BytesGenerator.new

      generator.init(params)
      generator.generate_bytes(String(pwd).to_java_bytes, hash)

      hash
    rescue Java::JavaLang::IllegalStateException => e
      raise Error, e.message
    end
  end
end
