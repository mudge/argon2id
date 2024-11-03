# frozen_string_literal: true

if RUBY_PLATFORM == "java"
  require "java"
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

    java_import "org.bouncycastle.util.Arrays"
    java_import "org.bouncycastle.crypto.params.Argon2Parameters"
    java_import "org.bouncycastle.crypto.generators.Argon2BytesGenerator"

    # Provide signature-specific aliases for overloaded methods to improve
    # performance, see
    # https://github.com/jruby/jruby/wiki/ImprovingJavaIntegrationPerformance
    class Arrays
      java_alias :constant_time_byte_arrays_are_equal?, :constantTimeAreEqual, [Java::byte[], Java::byte[]]
    end

    class Argon2BytesGenerator
      java_alias :generate_byte_array, :generateBytes, [Java::byte[], Java::byte[]]
    end

    def self.hash_encoded(t_cost, m_cost, parallelism, pwd, salt, hashlen)
      salt_bytes = salt.to_java_bytes
      pwd_bytes = pwd.to_java_bytes
      output = hash_raw(t_cost, m_cost, parallelism, pwd_bytes, salt_bytes, hashlen)

      encoder = Java::JavaUtil::Base64.getEncoder.withoutPadding
      encoded_salt = encoder.encodeToString(salt_bytes)
      encoded_output = encoder.encodeToString(output)

      "$argon2id$v=19$m=#{m_cost},t=#{t_cost},p=#{parallelism}" \
        "$#{encoded_salt}$#{encoded_output}"
    end

    def self.verify(encoded, pwd)
      password = Password.new(encoded)
      other_raw = hash_raw(
        password.t_cost,
        password.m_cost,
        password.parallelism,
        pwd.to_java_bytes,
        password.salt.to_java_bytes,
        password.output.bytesize
      )

      Arrays.constant_time_byte_arrays_are_equal?(
        password.output.to_java_bytes,
        other_raw
      )
    end

    def self.hash_raw(t_cost, m_cost, parallelism, pwd, salt, hashlen)
      raise Error, "Salt is too short" if salt.empty?

      hash = Java::byte[hashlen].new
      params = Argon2Parameters::Builder
        .new(Argon2Parameters::ARGON2_id)
        .withSalt(salt)
        .withParallelism(parallelism)
        .withMemoryAsKB(m_cost)
        .withIterations(t_cost)
        .build
      generator = Argon2BytesGenerator.new

      generator.init(params)
      generator.generate_byte_array(pwd, hash)

      hash
    rescue Java::JavaLang::IllegalStateException => e
      raise Error, e.message
    end
  end
end
