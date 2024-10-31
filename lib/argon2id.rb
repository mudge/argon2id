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
  DEFAULT_T_COST = 2
  DEFAULT_M_COST = 19456
  DEFAULT_PARALLELISM = 1
  DEFAULT_SALT_LEN = 16
  DEFAULT_OUTPUT_LEN = 32

  @t_cost = DEFAULT_T_COST
  @m_cost = DEFAULT_M_COST
  @parallelism = DEFAULT_PARALLELISM
  @salt_len = DEFAULT_SALT_LEN
  @output_len = DEFAULT_OUTPUT_LEN

  class << self
    attr_accessor :t_cost, :m_cost, :parallelism, :salt_len, :output_len
  end
end
