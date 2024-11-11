# frozen_string_literal: true

if RUBY_PLATFORM == "java"
  require "java"
  require "openssl"

  module Argon2id
    Error = Class.new(StandardError)

    class Password
      def self.hash_encoded(t_cost, m_cost, parallelism, pwd, salt, hashlen)
        raise Error, "Salt is too short" if salt.empty?

        salt_bytes = salt.to_java_bytes
        output = Java::byte[hashlen].new
        params = Java::OrgBouncycastleCryptoParams::Argon2Parameters::Builder
          .new(Java::OrgBouncycastleCryptoParams::Argon2Parameters::ARGON2_id)
          .with_version(Java::OrgBouncycastleCryptoParams::Argon2Parameters::ARGON2_VERSION_13)
          .with_iterations(t_cost)
          .with_memory_as_kb(m_cost)
          .with_parallelism(parallelism)
          .with_salt(salt_bytes)
          .build
        generator = Java::OrgBouncycastleCryptoGenerators::Argon2BytesGenerator.new

        generator.init(params)
        generator.generate_bytes(pwd.to_java_bytes, output)

        encoder = Java::JavaUtil::Base64.get_encoder.without_padding
        encoded_salt = encoder.encode_to_string(salt_bytes)
        encoded_output = encoder.encode_to_string(output)

        "$argon2id$v=19$m=#{m_cost},t=#{t_cost},p=#{parallelism}" \
          "$#{encoded_salt}$#{encoded_output}"
      rescue Java::JavaLang::IllegalStateException => e
        raise Error, e.message
      end

      private_class_method :hash_encoded

      private

      def verify(pwd)
        other_output = Java::byte[output.bytesize].new
        params = Java::OrgBouncycastleCryptoParams::Argon2Parameters::Builder
          .new(Java::OrgBouncycastleCryptoParams::Argon2Parameters::ARGON2_id)
          .with_version(version)
          .with_iterations(t_cost)
          .with_memory_as_kb(m_cost)
          .with_parallelism(parallelism)
          .with_salt(salt.to_java_bytes)
          .build
        generator = Java::OrgBouncycastleCryptoGenerators::Argon2BytesGenerator.new
        generator.init(params)
        generator.generate_bytes(pwd.to_java_bytes, other_output)

        Java::OrgBouncycastleUtil::Arrays.constant_time_are_equal?(
          output.to_java_bytes,
          other_output
        )
      end
    end
  end
else
  begin
    ::RUBY_VERSION =~ /(\d+\.\d+)/
    require_relative "#{Regexp.last_match(1)}/argon2id"
  rescue LoadError
    require "argon2id/argon2id"
  end
end
