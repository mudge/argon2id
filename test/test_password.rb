# frozen_string_literal: true

require "minitest/autorun"
require "argon2id"

class TestPassword < Minitest::Test
  def test_create_returns_encoded_password_with_defaults
    password = Argon2id::Password.create("opensesame")

    assert password.to_s.start_with?("$argon2id$")
    assert password.to_s.include?("t=2")
    assert password.to_s.include?("m=19456")
  end

  def test_create_options_can_override_parameters
    password = Argon2id::Password.create("opensesame", t_cost: 2, m_cost: 256)

    assert password.to_s.include?("t=2")
    assert password.to_s.include?("m=256")
  end

  def test_create_uses_argon2id_configuration
    Argon2id.t_cost = 2
    Argon2id.m_cost = 256

    password = Argon2id::Password.create("opensesame")

    assert password.to_s.include?("t=2")
    assert password.to_s.include?("m=256")
  ensure
    Argon2id.t_cost = Argon2id::DEFAULT_T_COST
    Argon2id.m_cost = Argon2id::DEFAULT_M_COST
  end

  def test_create_coerces_pwd_to_string
    password = Argon2id::Password.create(123, t_cost: 2, m_cost: 256)

    assert password.to_s.start_with?("$argon2id$")
  end

  def test_create_coerces_costs_to_integer
    password = Argon2id::Password.create("opensesame", t_cost: "2", m_cost: "256", parallelism: "1", salt_len: "8", output_len: "32")

    assert password.to_s.start_with?("$argon2id$")
  end

  def test_create_raises_if_given_non_integer_costs
    assert_raises(ArgumentError) do
      Argon2id::Password.create("opensesame", t_cost: "not an integer")
    end
  end

  def test_equals_correct_password
    password = Argon2id::Password.create("opensesame", t_cost: 2, m_cost: 256)

    assert password == "opensesame"
  end

  def test_does_not_equal_invalid_password
    password = Argon2id::Password.create("opensesame", t_cost: 2, m_cost: 256)

    refute password == "notopensesame"
  end

  def test_is_password_returns_true_with_correct_password
    password = Argon2id::Password.create("opensesame", t_cost: 2, m_cost: 256)

    assert password.is_password?("opensesame")
  end

  def test_is_password_returns_false_with_incorrect_password
    password = Argon2id::Password.create("opensesame", t_cost: 2, m_cost: 256)

    refute password.is_password?("notopensesame")
  end

  def test_raises_if_verifying_with_invalid_encoded_password
    password = Argon2id::Password.new("invalid")

    error = assert_raises(Argon2id::Error) do
      password.is_password?("opensesame")
    end

    assert_equal "Decoding failed", error.message
  end
end
