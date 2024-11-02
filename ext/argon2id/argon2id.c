#include <ruby.h>
#include <stdint.h>

#include "argon2.h"

#define UNUSED(x) (void)(x)

VALUE mArgon2id, cArgon2idError;

/* call-seq: hash_encoded(t_cost, m_cost, parallelism, pwd, salt, output_len)
 *
 * Hashes a password with Argon2id, producing an encoded hash.
 *
 * - +t_cost+: number of iterations
 * - +m_cost+: sets memory usage to +m_cost+ kibibytes
 * - +parallelism+: number of threads and compute lanes
 * - +pwd+: the password
 * - +salt+: the salt
 * - +output_len+: desired length of the hash in bytes
 */
static VALUE
rb_argon2id_hash_encoded(VALUE module, VALUE iterations, VALUE memory, VALUE threads, VALUE pwd, VALUE salt, VALUE hashlen)
{
  uint32_t t_cost, m_cost, parallelism;
  size_t encodedlen, outlen;
  char * encoded;
  int result;
  VALUE hash;

  UNUSED(module);

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

/* call-seq: verify(encoded, pwd)
 *
 * Verifies a password against an encoded string.
 */
static VALUE
rb_argon2id_verify(VALUE module, VALUE encoded, VALUE pwd) {
  int result;

  UNUSED(module);

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
  mArgon2id = rb_define_module("Argon2id");
  cArgon2idError = rb_define_class_under(mArgon2id, "Error", rb_eStandardError);
  rb_define_singleton_method(mArgon2id, "hash_encoded", rb_argon2id_hash_encoded, 6);
  rb_define_singleton_method(mArgon2id, "verify", rb_argon2id_verify, 2);
}
