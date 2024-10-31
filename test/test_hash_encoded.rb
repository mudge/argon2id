# frozen_string_literal: true

require "minitest/autorun"
require "argon2id"

class TestHashEncoded < Minitest::Test
  def test_valid_password_and_salt_encodes_successfully
    encoded = Argon2id.hash_encoded(2, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(16), 32)

    assert encoded.start_with?("$argon2id$")
  end

  def test_valid_password_does_not_include_trailing_null_byte
    encoded = Argon2id.hash_encoded(2, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(16), 32)

    refute encoded.end_with?("\x00")
  end

  def test_raises_with_too_short_output
    error = assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(2, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(16), 1)
    end

    assert_equal "Output is too short", error.message
  end

  def test_raises_with_too_large_output
    assert_raises(RangeError) do
      Argon2id.hash_encoded(2, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(16), 4294967296)
    end
  end

  def test_raises_with_too_few_lanes
    error = assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(2, 19456, 0, "opensesame", OpenSSL::Random.random_bytes(16), 32)
    end

    assert_equal "Too few lanes", error.message
  end

  def test_raises_with_too_small_memory_cost
    error = assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(2, 0, 1, "opensesame", OpenSSL::Random.random_bytes(16), 32)
    end

    assert_equal "Memory cost is too small", error.message
  end

  def test_raises_with_too_large_memory_cost
    assert_raises(RangeError) do
      Argon2id.hash_encoded(2, 4294967296, 1, "opensesame", OpenSSL::Random.random_bytes(16), 32)
    end
  end

  def test_raises_with_too_small_time_cost
    error = assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(0, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(16), 32)
    end

    assert_equal "Time cost is too small", error.message
  end

  def test_raises_with_too_large_time_cost
    assert_raises(RangeError) do
      Argon2id.hash_encoded(4294967296, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(16), 32)
    end
  end

  def test_raises_with_too_short_salt
    error = assert_raises(Argon2id::Error) do
      Argon2id.hash_encoded(2, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(1), 32)
    end

    assert_equal "Salt is too short", error.message
  end

  def test_raises_with_too_long_salt
    assert_raises(RangeError) do
      Argon2id.hash_encoded(2, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(4294967296), 32)
    end
  end
end
