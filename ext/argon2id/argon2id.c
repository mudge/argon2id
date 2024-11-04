#include <ruby.h>
#include <stdint.h>

#include "argon2.h"

#define UNUSED(x) (void)(x)

VALUE mArgon2id, cArgon2idError, cArgon2idPassword;
ID id_encoded;

static VALUE
rb_argon2id_hash_encoded(VALUE klass, VALUE iterations, VALUE memory, VALUE threads, VALUE pwd, VALUE salt, VALUE hashlen)
{
  uint32_t t_cost, m_cost, parallelism;
  size_t encodedlen, outlen;
  char * encoded;
  int result;
  VALUE hash;

  UNUSED(klass);

  t_cost = FIX2INT(iterations);
  m_cost = FIX2INT(memory);
  parallelism = FIX2INT(threads);
  outlen = FIX2INT(hashlen);

  encodedlen = argon2_encodedlen(t_cost, m_cost, parallelism, (uint32_t)RSTRING_LEN(salt), (uint32_t)outlen, Argon2_id);
  encoded = malloc(encodedlen);
  if (!encoded) {
    rb_raise(rb_eNoMemError, "not enough memory to allocate for encoded password");
  }

  result = argon2id_hash_encoded(t_cost, m_cost, parallelism, StringValuePtr(pwd), RSTRING_LEN(pwd), StringValuePtr(salt), RSTRING_LEN(salt), outlen, encoded, encodedlen);

  if (result != ARGON2_OK) {
    free(encoded);
    rb_raise(cArgon2idError, "%s", argon2_error_message(result));
  }

  hash = rb_str_new_cstr(encoded);
  free(encoded);

  return hash;
}

static VALUE
rb_argon2id_verify(VALUE self, VALUE pwd) {
  int result;
  VALUE encoded;

  encoded = rb_ivar_get(self, id_encoded);
  result = argon2id_verify(StringValueCStr(encoded), StringValuePtr(pwd), RSTRING_LEN(pwd));
  if (result == ARGON2_OK) {
    return Qtrue;
  }
  if (result == ARGON2_VERIFY_MISMATCH) {
    return Qfalse;
  }
  if (result == ARGON2_DECODING_FAIL || result == ARGON2_DECODING_LENGTH_FAIL) {
    rb_raise(rb_eArgError, "%s", argon2_error_message(result));
  }

  rb_raise(cArgon2idError, "%s", argon2_error_message(result));
}

void
Init_argon2id(void)
{
  id_encoded = rb_intern("@encoded");

  mArgon2id = rb_define_module("Argon2id");
  cArgon2idError = rb_define_class_under(mArgon2id, "Error", rb_eStandardError);
  cArgon2idPassword = rb_define_class_under(mArgon2id, "Password", rb_cObject);
  rb_define_singleton_method(cArgon2idPassword, "hash_encoded", rb_argon2id_hash_encoded, 6);
  rb_define_private_method(cArgon2idPassword, "verify", rb_argon2id_verify, 1);
}
