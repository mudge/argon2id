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

  def test_owasp_2_uses_t_cost_of_2
    assert_equal 2, Argon2id::OWASP_2[:t_cost]
  end

  def test_owasp_2_uses_parallelism_of_1
    assert_equal 1, Argon2id::OWASP_2[:parallelism]
  end

  def test_owasp_2_uses_m_cost_of_19_mib
    assert_equal 19_456, Argon2id::OWASP_2[:m_cost]
  end

  def test_owasp_2_uses_salt_len_of_128_bits
    assert_equal 128/8, Argon2id::OWASP_2[:salt_len]
  end

  def test_owasp_2_uses_output_len_of_256_bits
    assert_equal 256/8, Argon2id::OWASP_2[:output_len]
  end

  def test_rfc_9106_high_memory_uses_t_cost_of_1
    assert_equal 1, Argon2id::RFC_9106_HIGH_MEMORY[:t_cost]
  end

  def test_rfc_9106_high_memory_uses_parallelism_of_4
    assert_equal 4, Argon2id::RFC_9106_HIGH_MEMORY[:parallelism]
  end

  def test_rfc_9106_high_memory_uses_m_cost_of_2_gib
    assert_equal 2**21, Argon2id::RFC_9106_HIGH_MEMORY[:m_cost]
  end

  def test_rfc_9106_high_memory_uses_salt_len_of_128_bits
    assert_equal 128/8, Argon2id::RFC_9106_HIGH_MEMORY[:salt_len]
  end

  def test_rfc_9106_high_memory_uses_output_len_of_256_bits
    assert_equal 256/8, Argon2id::RFC_9106_HIGH_MEMORY[:output_len]
  end

  def test_rfc_9106_low_memory_uses_t_cost_of_3
    assert_equal 3, Argon2id::RFC_9106_LOW_MEMORY[:t_cost]
  end

  def test_rfc_9106_low_memory_uses_parallelism_of_4
    assert_equal 4, Argon2id::RFC_9106_LOW_MEMORY[:parallelism]
  end

  def test_rfc_9106_low_memory_uses_m_cost_of_64_mib
    assert_equal 2**16, Argon2id::RFC_9106_LOW_MEMORY[:m_cost]
  end

  def test_rfc_9106_low_memory_uses_salt_len_of_128_bits
    assert_equal 128/8, Argon2id::RFC_9106_LOW_MEMORY[:salt_len]
  end

  def test_rfc_9106_low_memory_uses_output_len_of_256_bits
    assert_equal 256/8, Argon2id::RFC_9106_LOW_MEMORY[:output_len]
  end

  def test_set_defaults_sets_t_cost
    Argon2id.set_defaults(t_cost: 1)

    assert_equal 1, Argon2id.t_cost
  ensure
    Argon2id.t_cost = Argon2id::DEFAULT_T_COST
  end

  def test_set_defaults_does_not_change_missing_parameters
    Argon2id.m_cost = 47_014
    Argon2id.set_defaults(t_cost: 1)

    assert_equal 47_014, Argon2id.m_cost
  ensure
    Argon2id.t_cost = Argon2id::DEFAULT_T_COST
    Argon2id.m_cost = Argon2id::DEFAULT_M_COST
  end

  def test_set_defaults_sets_m_cost
    Argon2id.set_defaults(m_cost: 47_104)

    assert_equal 47_104, Argon2id.m_cost
  ensure
    Argon2id.m_cost = Argon2id::DEFAULT_M_COST
  end

  def test_set_defaults_sets_parallelism
    Argon2id.set_defaults(parallelism: 4)

    assert_equal 4, Argon2id.parallelism
  ensure
    Argon2id.parallelism = Argon2id::DEFAULT_PARALLELISM
  end

  def test_set_defaults_sets_salt_len
    Argon2id.set_defaults(salt_len: 32)

    assert_equal 32, Argon2id.salt_len
  ensure
    Argon2id.salt_len = Argon2id::DEFAULT_SALT_LEN
  end

  def test_set_defaults_sets_output_len
    Argon2id.set_defaults(output_len: 32)

    assert_equal 32, Argon2id.output_len
  ensure
    Argon2id.output_len = Argon2id::DEFAULT_OUTPUT_LEN
  end

  def test_set_defaults_returns_nil
    assert_nil Argon2id.set_defaults(output_len: 32)
  ensure
    Argon2id.output_len = Argon2id::DEFAULT_OUTPUT_LEN
  end
end
