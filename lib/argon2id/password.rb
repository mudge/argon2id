# frozen_string_literal: true

require "java" if RUBY_PLATFORM == "java"
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
  # To wrap an encoded Argon2id password hash, use Argon2id::Password.new:
  #
  #   password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")
  #
  # You can then verify it matches a given plain text:
  #
  #   password == "password"     #=> true
  #   password == "not password" #=> false
  #
  #   password.is_password?("password")     #=> true
  #   password.is_password?("not password") #=> false
  #
  # You can read various parameters out of a password hash:
  #
  #   password.version     #=> 19
  #   password.m_cost      #=> 19456
  #   password.t_cost      #=> 2
  #   password.parallelism #=> 1
  #   password.salt        #=>  "somesalt"
  class Password
    # A regular expression to match valid hashes.
    PATTERN = %r{
      \A
      \$
      argon2id
      (?:\$v=(\d+))?
      \$m=(\d+)
      ,t=(\d+)
      ,p=(\d+)
      \$
      ([a-zA-Z0-9+/]+)
      \$
      ([a-zA-Z0-9+/]+)
      \z
    }x.freeze

    # The encoded password hash.
    attr_reader :encoded

    # The version number of the hashing function.
    attr_reader :version

    # The "time cost" of the hashing function.
    attr_reader :t_cost

    # The "memory cost" of the hashing function.
    attr_reader :m_cost

    # The number of threads and compute lanes of the hashing function.
    attr_reader :parallelism

    # The salt.
    attr_reader :salt

    # The hash output.
    attr_reader :output

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
        hash_encoded(
          Integer(t_cost),
          Integer(m_cost),
          Integer(parallelism),
          String(pwd),
          OpenSSL::Random.random_bytes(Integer(salt_len)),
          Integer(output_len)
        )
      )
    end

    if RUBY_PLATFORM == "java"
      def self.hash_encoded(t_cost, m_cost, parallelism, pwd, salt, hashlen)
        raise Error, "Salt is too short" if salt.empty?

        salt_bytes = salt.to_java_bytes
        output = Java::byte[hashlen].new
        params = Java::OrgBouncycastleCryptoParams::Argon2Parameters::Builder
          .new(Java::OrgBouncycastleCryptoParams::Argon2Parameters::ARGON2_id)
          .with_salt(salt_bytes)
          .with_parallelism(parallelism)
          .with_memory_as_kb(m_cost)
          .with_iterations(t_cost)
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
    end

    private_class_method :hash_encoded

    # Create a new Password with the given encoded password hash.
    #
    #   password = Argon2id::Password.new("$argon2id$v=19$m=19456,t=2,p=1$FI8yp1gXbthJCskBlpKPoQ$nOfCCpS2r+I8GRN71cZND4cskn7YKBNzuHUEO3YpY2s")
    #
    # Raises an ArgumentError if given an invalid hash.
    def initialize(encoded)
      raise ArgumentError, "invalid hash" unless PATTERN =~ String(encoded)

      @encoded = $&
      @version = Integer($1 || 0x10)
      @m_cost = Integer($2)
      @t_cost = Integer($3)
      @parallelism = Integer($4)
      @salt = $5.unpack1("m")
      @output = $6.unpack1("m")
    end

    # Return the encoded password hash.
    alias_method :to_s, :encoded

    # Compare the password with the given plain text, returning true if it
    # verifies successfully.
    #
    #   password = Argon2id::Password.new("$argon2id$v=19$m=19456,t=2,p=1$FI8yp1gXbthJCskBlpKPoQ$nOfCCpS2r+I8GRN71cZND4cskn7YKBNzuHUEO3YpY2s")
    #   password == "password"    #=> true
    #   password == "notpassword" #=> false
    def ==(other)
      verify(String(other))
    end

    alias_method :is_password?, :==

    if RUBY_PLATFORM == "java"
      def verify(pwd)
        other_output = Java::byte[output.bytesize].new
        params = Java::OrgBouncycastleCryptoParams::Argon2Parameters::Builder
          .new(Java::OrgBouncycastleCryptoParams::Argon2Parameters::ARGON2_id)
          .with_salt(salt.to_java_bytes)
          .with_parallelism(parallelism)
          .with_memory_as_kb(m_cost)
          .with_iterations(t_cost)
          .build
        generator = Java::OrgBouncycastleCryptoGenerators::Argon2BytesGenerator.new
        generator.init(params)
        generator.generate_bytes(pwd.to_java_bytes, other_output)

        Java::OrgBouncycastleUtil::Arrays.constant_time_are_equal?(
          output.to_java_bytes,
          other_output
        )
      end

      private :verify
    end
  end
end
