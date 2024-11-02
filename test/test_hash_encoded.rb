# frozen_string_literal: true

require "minitest/autorun"
require "argon2id"

class TestHashEncoded < Minitest::Test
  def test_valid_password_and_salt_encodes_successfully
    encoded = Argon2id.hash_encoded(2, 256, 1, "password", "somesalt", 32)

    assert_equal "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4", encoded
  end

  def test_valid_password_does_not_include_trailing_null_byte
    encoded = Argon2id.hash_encoded(2, 256, 1, "password", "somesalt", 32)

    refute encoded.end_with?("\x00")
  end

  def test_raises_with_too_short_output
    assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(2, 256, 1, "password", "somesalt", 1)
    end
  end

  def test_raises_with_too_few_lanes
    assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(2, 256, 0, "password", "somesalt", 32)
    end
  end

  def test_raises_with_too_small_memory_cost
    assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(2, 0, 1, "password", "somesalt", 32)
    end
  end

  def test_raises_with_too_small_time_cost
    assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(0, 256, 1, "password", "somesalt", 32)
    end
  end

  def test_raises_with_too_short_salt
    assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(2, 256, 1, "password", "", 32)
    end
  end
end
