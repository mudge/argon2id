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

  def test_salt_returns_the_original_salt
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal "somesalt", password.salt
  end

  def test_salt_returns_raw_bytes
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$KmIxrXv4lrnSJPO0LN7Gdw$lB3724qLPL9MNi10lkvIb4VxIk3q841CLvq0WTCZ0VQ")

    assert_equal "*b1\xAD{\xF8\x96\xB9\xD2$\xF3\xB4,\xDE\xC6w".b, password.salt
  end

  def test_raises_for_invalid_hashes
    assert_raises(ArgumentError) do
      Argon2id::Password.new("not a valid hash")
    end
  end

  def test_raises_for_partial_hashes
    assert_raises(ArgumentError) do
      Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$KmIxrXv4lrnSJPO0LN7Gdw")
    end
  end

  def test_raises_for_hashes_with_null_bytes
    assert_raises(ArgumentError) do
      Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4\x00foo")
    end
  end

  def test_raises_for_non_argon2id_hashes
    assert_raises(ArgumentError) do
      Argon2id::Password.new("$argon2i$v=19$m=256,t=2,p=1$c29tZXNhbHQ$iekCn0Y3spW+sCcFanM2xBT63UP2sghkUoHLIUpWRS8")
    end
  end

  def test_salt_supports_versionless_hashes
    password = Argon2id::Password.new("$argon2id$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal "somesalt", password.salt
  end

  def test_coerces_given_hash_to_string
    password = Argon2id::Password.create("password")

    assert Argon2id::Password.new(password) == "password"
  end

  def test_extracting_version_from_hash
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal 19, password.version
  end

  def test_extracting_version_from_versionless_hash
    password = Argon2id::Password.new("$argon2id$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal 16, password.version
  end

  def test_extracting_time_cost_from_hash
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal 2, password.t_cost
  end

  def test_extracting_time_cost_from_versionless_hash
    password = Argon2id::Password.new("$argon2id$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal 2, password.t_cost
  end

  def test_extracting_memory_cost_from_hash
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal 256, password.m_cost
  end

  def test_extracting_memory_cost_from_versionless_hash
    password = Argon2id::Password.new("$argon2id$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal 256, password.m_cost
  end

  def test_extracting_parallelism_from_hash
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal 1, password.parallelism
  end

  def test_extracting_parallelism_from_versionless_hash
    password = Argon2id::Password.new("$argon2id$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal 1, password.parallelism
  end

  def test_extracting_output_from_hash
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert_equal "\x9D\xFE\xB9\x10\xE8\v\xAD\x03\x11\xFE\xE2\x0F\x9C\x0E+\x12\xC1y\x87\xB4\xCA\xC9\f.\xF5M[0!\xC6\x8B\xFE".b, password.output
  end

  def test_libargon2_test_case_1
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    assert password == "password"
  end

  def test_libargon2_test_case_1_returns_false_with_incorrect_password
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4")

    refute password == "not password"
  end

  def test_libargon2_test_case_2
    password = Argon2id::Password.new("$argon2id$v=19$m=256,t=2,p=2$c29tZXNhbHQ$bQk8UB/VmZZF4Oo79iDXuL5/0ttZwg2f/5U52iv1cDc")

    assert password == "password"
  end

  def test_encoded_password_does_not_include_trailing_null_byte
    password = Argon2id::Password.create("password", t_cost: 2, m_cost: 256, salt_len: 8)

    refute password.to_s.end_with?("\x00")
  end

  def test_raises_with_too_short_output
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", t_cost: 2, m_cost: 256, salt_len: 8, output_len: 1)
    end
  end

  def test_raises_with_too_few_threads_and_compute_lanes
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", t_cost: 2, m_cost: 256, parallelism: 0, salt_len: 8)
    end
  end

  def test_raises_with_too_small_memory_cost
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", t_cost: 2, m_cost: 0, salt_len: 8)
    end
  end

  def test_raises_with_too_small_time_cost
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", t_cost: 0, m_cost: 256, salt_len: 8)
    end
  end

  def test_raises_with_too_short_salt
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", t_cost: 2, m_cost: 256, salt_len: 0)
    end
  end
end
