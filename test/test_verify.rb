# frozen_string_literal: true

require "minitest/autorun"
require "argon2id"

class TestVerify < Minitest::Test
  def test_returns_true_with_correct_password
    assert Argon2id.verify(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4",
      "password"
    )
  end

  def test_returns_false_with_incorrect_password
    refute Argon2id.verify(
      "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4",
      "not password"
    )
  end

  def test_raises_if_given_invalid_encoded
    assert_raises(ArgumentError) do
      Argon2id.verify("", "opensesame")
    end
  end

  def test_raises_if_given_encoded_with_null_byte
    assert_raises(ArgumentError) do
      Argon2id.verify(
        "$argon2id$v=19$m=256,t=2,p=1$c29tZXNhbHQ$nf65EOgLrQMR/uIPnA4rEsF5h7TKyQwu9U1bMCHGi/4\x00foo",
        "password"
      )
    end
  end
end
