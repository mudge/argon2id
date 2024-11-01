# frozen_string_literal: true

begin
  ::RUBY_VERSION =~ /(\d+\.\d+)/
  require_relative "#{Regexp.last_match(1)}/argon2id.so"
rescue LoadError
  require "argon2id.so"
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
end
