# frozen_string_literal: true

require "minitest/autorun"
require "argon2id"

class StringLike
  def initialize(str)
    @str = str
  end

  def to_s
    @str
  end
end

class TestPassword < Minitest::Test
  def test_valid_hash_with_argon2id_hash_returns_true
    assert Argon2id::Password.valid_hash?(
      "$argon2id$v=19$m=65536,t=2,p=1$c29tZXNhbHQ" \
      "$CTFhFdXPJO1aFaMaO6Mm5c8y7cJHAph8ArZWb2GRPPc"
    )
  end

  def test_valid_hash_with_versionless_argon2id_hash_returns_true
    assert Argon2id::Password.valid_hash?(
      "$argon2id$m=65536,t=2,p=1$c29tZXNhbHQ" \
      "$CTFhFdXPJO1aFaMaO6Mm5c8y7cJHAph8ArZWb2GRPPc"
    )
  end

  def test_valid_hash_with_argon2i_hash_returns_false
    refute Argon2id::Password.valid_hash?(
      "$argon2i$m=65536,t=2,p=1$c29tZXNhbHQ" \
      "$9sTbSlTio3Biev89thdrlKKiCaYsjjYVJxGAL3swxpQ"
    )
  end

  def test_valid_hash_with_partial_argon2id_hash_returns_false
    refute Argon2id::Password.valid_hash?(
      "$argon2id$v=19$m=65536,t=2,p=1$c29tZXNhbHQ"
    )
  end

  def test_valid_hash_with_argon2id_hash_with_null_bytes_returns_false
    refute Argon2id::Password.valid_hash?(
      "$argon2id$v=19$m=65536,t=2,p=1$c29tZXNhbHQ" \
      "$CTFhFdXPJO1aFaMaO6Mm5c8y7cJHAph8ArZWb2GRPPc\x00foo"
    )
  end

  def test_valid_hash_with_bcrypt_hash_returns_false
    refute Argon2id::Password.valid_hash?(
      "$2a$12$stsRn7Mi9r02.keRyF4OK.Aq4UWOU185lWggfUQfcupAi.b7AI/nS"
    )
  end

  def test_new_m_65536_t_2_p_1_equals_password
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=65536,t=2,p=1$c29tZXNhbHQ" \
      "$CTFhFdXPJO1aFaMaO6Mm5c8y7cJHAph8ArZWb2GRPPc"
    )

    assert password == "password"
  end

  def test_new_m_262144_t_2_p_1_equals_password
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=262144,t=2,p=1$c29tZXNhbHQ" \
      "$eP4eyR+zqlZX1y5xCFTkw9m5GYx0L5YWwvCFvtlbLow"
    )

    assert password == "password"
  end

  def test_new_m_256_t_2_p_1_equals_password
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert password == "password"
  end

  def test_new_m_256_t_2_p_2_equals_password
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=2$c29tZXNhbHQ" \
      "$bQk8UB/VmZZF4Oo79iDXuL5/0ttZwg2f/5U52iv1cDc"
    )

    assert password == "password"
  end

  def test_new_m_65536_t_1_p_1_equals_password
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=65536,t=1,p=1$c29tZXNhbHQ" \
      "$9qWtwbpyPd3vm1rB1GThgPzZ3/ydHL92zKL+15XZypg"
    )

    assert password == "password"
  end

  def test_new_m_65536_t_4_p_1_equals_password
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=65536,t=4,p=1$c29tZXNhbHQ" \
      "$kCXUjmjvc5XMqQedpMTsOv+zyJEf5PhtGiUghW9jFyw"
    )

    assert password == "password"
  end

  def test_new_m_65536_t_2_p_1_equals_differentpassword
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=65536,t=2,p=1$c29tZXNhbHQ" \
      "$C4TWUs9rDEvq7w3+J4umqA32aWKB1+DSiRuBfYxFj94"
    )

    assert password == "differentpassword"
  end

  def test_new_m_65536_t_2_p_1_with_diffsalt_equals_password
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=65536,t=2,p=1$ZGlmZnNhbHQ" \
      "$vfMrBczELrFdWP0ZsfhWsRPaHppYdP3MVEMIVlqoFBw"
    )

    assert password == "password"
  end

  def test_new_with_versionless_hash_equals_password
    password = Argon2id::Password.new(
      "$argon2id$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$2gcOV25Q8vOKPIl8vdxsf7QCjocJcf+erntOGHkpXm4"
    )

    assert password == "password"
  end

  def test_new_with_non_argon2id_hash_raises_argument_error
    assert_raises(ArgumentError) do
      Argon2id::Password.new(
        "$argon2i$m=65536,t=2,p=1$c29tZXNhbHQ" \
        "$9sTbSlTio3Biev89thdrlKKiCaYsjjYVJxGAL3swxpQ"
      )
    end
  end

  def test_new_with_invalid_hash_raises_argument_error
    assert_raises(ArgumentError) do
      Argon2id::Password.new("not a valid hash")
    end
  end

  def test_new_with_nil_raises_argument_error
    assert_raises(ArgumentError) do
      Argon2id::Password.new(nil)
    end
  end

  def test_new_with_coercible_equals_password
    password = Argon2id::Password.new(
      StringLike.new(
        "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
        "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
      )
    )

    assert password == "password"
  end

  def test_encoded_returns_the_full_encoded_hash
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert_equal(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4",
      password.encoded
    )
  end

  def test_version_returns_the_version
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert_equal(19, password.version)
  end

  def test_version_with_no_version_returns_the_default_version
    password = Argon2id::Password.new(
      "$argon2id$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert_equal(16, password.version)
  end

  def test_m_cost_returns_m_cost
    password = Argon2id::Password.new(
      "$argon2id$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert_equal(256, password.m_cost)
  end

  def test_t_cost_returns_t_cost
    password = Argon2id::Password.new(
      "$argon2id$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert_equal(2, password.t_cost)
  end

  def test_parallelism_returns_parallelism
    password = Argon2id::Password.new(
      "$argon2id$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert_equal(1, password.parallelism)
  end

  def test_salt_returns_decoded_salt
    password = Argon2id::Password.new(
      "$argon2id$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert_equal("somesalt", password.salt)
  end

  def test_salt_returns_decoded_binary_salt
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$FImSDfu1p8vf1mZBL2PCkg" \
      "$vG4bIkTJGMx6OvkLuKTeq37DTyAf8gF2Ouf3zSLlYVc"
    )

    assert_equal(
      "\x14\x89\x92\r\xFB\xB5\xA7\xCB\xDF\xD6fA/c\xC2\x92".b,
      password.salt
    )
  end

  def test_output_returns_decoded_output
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=65536,t=1,p=1$c29tZXNhbHQ" \
      "$9qWtwbpyPd3vm1rB1GThgPzZ3/ydHL92zKL+15XZypg"
    )

    assert_equal(
      "\xF6\xA5\xAD\xC1\xBAr=\xDD\xEF\x9BZ\xC1\xD4d\xE1\x80\xFC\xD9\xDF\xFC\x9D\x1C\xBFv\xCC\xA2\xFE\xD7\x95\xD9\xCA\x98".b,
      password.output
    )
  end

  def test_to_s_returns_the_full_encoded_hash
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert_equal(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4",
      password.to_s
    )
  end

  def test_equals_correct_password_returns_true
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert password == "password"
  end

  def test_equals_incorrect_password_returns_false
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    refute password == "differentpassword"
  end

  def test_equals_nil_returns_false
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    refute password == nil
  end

  def test_equals_coercible_correct_password_returns_true
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert password == StringLike.new("password")
  end

  def test_equals_coercible_incorrect_password_returns_false
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    refute password == StringLike.new("differentpassword")
  end

  def test_is_password_correct_password_returns_true
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert password.is_password?("password")
  end

  def test_is_password_incorrect_password_returns_false
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    refute password.is_password?("differentpassword")
  end

  def test_is_password_nil_returns_false
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    refute password.is_password?(nil)
  end

  def test_is_password_coercible_correct_password_returns_true
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    assert password.is_password?(StringLike.new("password"))
  end

  def test_is_password_coercible_incorrect_password_returns_false
    password = Argon2id::Password.new(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ" \
      "$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4"
    )

    refute password.is_password?(StringLike.new("differentpassword"))
  end

  def test_create_password_returns_password
    password = Argon2id::Password.create("password")

    assert_instance_of Argon2id::Password, password
  end

  def test_create_password_uses_default_t_cost
    password = Argon2id::Password.create("password")

    assert_equal 2, password.t_cost
  end

  def test_create_password_uses_default_m_cost
    password = Argon2id::Password.create("password")

    assert_equal 19_456, password.m_cost
  end

  def test_create_password_uses_default_parallelism
    password = Argon2id::Password.create("password")

    assert_equal 1, password.parallelism
  end

  def test_create_password_uses_default_salt_len
    password = Argon2id::Password.create("password")

    assert_equal 16, password.salt.bytesize
  end

  def test_create_password_uses_default_output_len
    password = Argon2id::Password.create("password")

    assert_equal 32, password.output.bytesize
  end

  def test_create_password_with_t_cost_changes_t_cost
    password = Argon2id::Password.create("password", t_cost: 1)

    assert_equal(1, password.t_cost)
  end

  def test_create_password_with_too_small_t_cost_raises_error
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", t_cost: 0)
    end
  end

  def test_create_password_with_m_cost_changes_m_cost
    password = Argon2id::Password.create("password", m_cost: 8)

    assert_equal(8, password.m_cost)
  end

  def test_create_password_with_too_small_m_cost_raises_error
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", m_cost: 0)
    end
  end

  def test_create_password_with_parallelism_changes_parallelism
    password = Argon2id::Password.create("password", parallelism: 2)

    assert_equal(2, password.parallelism)
  end

  def test_create_password_with_too_small_parallelism_raises_error
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", parallelism: 0)
    end
  end

  def test_create_password_with_too_small_salt_raises_error
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", salt_len: 0)
    end
  end

  def test_create_password_with_output_len_changes_output_len
    password = Argon2id::Password.create("password", output_len: 8)

    assert_equal 8, password.output.bytesize
  end

  def test_create_password_with_too_output_len_raises_error
    assert_raises(Argon2id::Error) do
      Argon2id::Password.create("password", output_len: 0)
    end
  end

  def test_create_password_inherits_t_cost_from_argon2id
    Argon2id.t_cost = 1

    password = Argon2id::Password.create("password")

    assert_equal(1, password.t_cost)
  ensure
    Argon2id.t_cost = Argon2id::DEFAULT_T_COST
  end

  def test_create_password_inherits_m_cost_from_argon2id
    Argon2id.m_cost = 8

    password = Argon2id::Password.create("password")

    assert_equal(8, password.m_cost)
  ensure
    Argon2id.m_cost = Argon2id::DEFAULT_M_COST
  end

  def test_create_password_inherits_parallelism_from_argon2id
    Argon2id.parallelism = 2

    password = Argon2id::Password.create("password")

    assert_equal(2, password.parallelism)
  ensure
    Argon2id.parallelism = Argon2id::DEFAULT_PARALLELISM
  end

  def test_create_password_inherits_salt_len_from_argon2id
    Argon2id.salt_len = 8

    password = Argon2id::Password.create("password")

    assert_equal(8, password.salt.bytesize)
  ensure
    Argon2id.salt_len = Argon2id::DEFAULT_SALT_LEN
  end

  def test_create_password_inherits_output_len_from_argon2id
    Argon2id.output_len = 8

    password = Argon2id::Password.create("password")

    assert_equal(8, password.output.bytesize)
  ensure
    Argon2id.output_len = Argon2id::DEFAULT_OUTPUT_LEN
  end

  def test_create_password_equals_correct_password
    password = Argon2id::Password.create("password")

    assert password == "password"
  end

  def test_create_password_does_not_equal_incorrect_password
    password = Argon2id::Password.create("password")

    refute password == "differentpassword"
  end

  def test_hashing_password_verifies_correct_password
    hash = Argon2id::Password.create("password").to_s
    password = Argon2id::Password.new(hash)

    assert password == "password"
  end

  def test_hashing_password_does_not_verify_incorrect_password
    hash = Argon2id::Password.create("password").to_s
    password = Argon2id::Password.new(hash)

    refute password == "differentpassword"
  end
end
