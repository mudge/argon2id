# frozen_string_literal: true

require "argon2id/extension"
require "argon2id/password"
require "argon2id/version"

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

  # OWASP Password Storage Cheat Sheet second recommended parameters.
  #
  # "m=19456 (19 MiB), t=2, p=1"
  #
  # These are the defaults used by Argon2id::Password.create if no other
  # keyword arguments are given.
  #
  # See https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#argon2id
  OWASP_2 = {
    t_cost: DEFAULT_T_COST,
    m_cost: DEFAULT_M_COST,
    parallelism: DEFAULT_PARALLELISM,
    salt_len: DEFAULT_SALT_LEN,
    output_len: DEFAULT_OUTPUT_LEN
  }.freeze

  # RFC 9106 first recommended parameters.
  #
  # "If a uniformly safe option that is not tailored to your application or
  # hardware is acceptable, select Argon2id with t=1 iteration, p=4 lanes,
  # m=2^(21) (2 GiB of RAM), 128-bit salt, and 256-bit tag size."
  #
  # See 4. Parameter Choice in https://datatracker.ietf.org/doc/rfc9106/
  RFC_9106_HIGH_MEMORY = {
    t_cost: 1,
    parallelism: 4,
    m_cost: 2_097_152,
    salt_len: 16,
    output_len: 32
  }.freeze

  # RFC 9106 second recommended parameters.
  #
  # "If much less memory is available, a uniformly safe option is Argon2id with
  # t=3 iterations, p=4 lanes, m=2^(16) (64 MiB of RAM), 128-bit salt, and
  # 256-bit tag size."
  #
  # See 4. Parameter Choice in https://datatracker.ietf.org/doc/rfc9106/
  RFC_9106_LOW_MEMORY = {
    t_cost: 3,
    parallelism: 4,
    m_cost: 65_536,
    salt_len: 16,
    output_len: 32
  }.freeze

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

    # Set default parameters used by Argon2id::Password.create
    #
    # - +:t_cost+: integer (default Argon2id.t_cost) the "time cost" given as a number of iterations
    # - +:m_cost+: integer (default Argon2id.m_cost) the "memory cost" given in kibibytes
    # - +:parallelism+: integer (default Argon2id.parallelism) the number of threads and compute lanes to use
    # - +:salt_len+: integer (default Argon2id.salt_len) the salt size in bytes
    # - +:output_len+: integer (default Argon2id.output_len) the desired length of the hash in bytes
    #
    # For example:
    #
    #   Argon2id.set_defaults(t_cost: 1, m_cost: 47104, parallelism: 1)
    #   Argon2id.set_defaults(**Argon2id::RFC_9106_HIGH_MEMORY)
    def set_defaults(t_cost: self.t_cost, m_cost: self.m_cost, parallelism: self.parallelism, salt_len: self.salt_len, output_len: self.output_len)
      @t_cost = t_cost
      @m_cost = m_cost
      @parallelism = parallelism
      @salt_len = salt_len
      @output_len = output_len

      nil
    end
  end
end
