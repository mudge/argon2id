# frozen_string_literal: true

require "minitest/autorun"
require "argon2id"

class TestVerify < Minitest::Test
  def test_returns_true_with_correct_password
    encoded = Argon2id.hash_encoded(2, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(16), 32)

    assert Argon2id.verify(encoded, "opensesame")
  end

  def test_returns_false_with_incorrect_password
    encoded = Argon2id.hash_encoded(2, 19456, 1, "opensesame", OpenSSL::Random.random_bytes(16), 32)

    refute Argon2id.verify(encoded, "notopensesame")
  end

  def test_raises_if_given_invalid_encoded
    assert_raises(Argon2id::Error) do
      Argon2id.verify("", "opensesame")
    end
  end
end
