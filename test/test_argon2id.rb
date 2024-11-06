# frozen_string_literal: true

require "minitest/autorun"
require "argon2id"

class TestArgon2id < Minitest::Test
  def test_t_cost_is_default_t_cost
    assert_equal 2, Argon2id.t_cost
  end

  def test_m_cost_is_default_m_cost
    assert_equal 19_456, Argon2id.m_cost
  end

  def test_parallelism_is_default_parallelism
    assert_equal 1, Argon2id.parallelism
  end

  def test_salt_len_is_default_salt_len
    assert_equal 16, Argon2id.salt_len
  end

  def test_output_len_is_default_output_len
    assert_equal 32, Argon2id.output_len
  end

  def test_t_cost_can_be_overridden
    Argon2id.t_cost = 1

    assert_equal 1, Argon2id.t_cost
  ensure
    Argon2id.t_cost = Argon2id::DEFAULT_T_COST
  end

  def test_m_cost_can_be_overridden
    Argon2id.m_cost = 256

    assert_equal 256, Argon2id.m_cost
  ensure
    Argon2id.m_cost = Argon2id::DEFAULT_M_COST
  end

  def test_parallelism_can_be_overridden
    Argon2id.parallelism = 2

    assert_equal 2, Argon2id.parallelism
  ensure
    Argon2id.parallelism = Argon2id::DEFAULT_PARALLELISM
  end

  def test_salt_len_can_be_overridden
    Argon2id.salt_len = 8

    assert_equal 8, Argon2id.salt_len
  ensure
    Argon2id.salt_len = Argon2id::DEFAULT_SALT_LEN
  end

  def test_output_len_can_be_overridden
    Argon2id.output_len = 16

    assert_equal 16, Argon2id.output_len
  ensure
    Argon2id.output_len = Argon2id::DEFAULT_OUTPUT_LEN
  end
end
