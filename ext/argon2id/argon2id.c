#include <ruby.h>
#include <ruby/thread.h>
#include <stdint.h>

#include "argon2.h"

#define UNUSED(x) (void)(x)

VALUE mArgon2id, cArgon2idError, cArgon2idPassword;
ID id_encoded;

struct hash_encoded_args {
  uint32_t t_cost;
  uint32_t m_cost;
  uint32_t parallelism;
  const char *pwd;
  size_t pwdlen;
  const char *salt;
  size_t saltlen;
  uint32_t outlen;
  char *encoded;
  size_t encodedlen;
  int result;
};

static void *
nogvl_hash_encoded(void *data)
{
  struct hash_encoded_args *args = data;
  args->result = argon2id_hash_encoded(args->t_cost, args->m_cost,
    args->parallelism, args->pwd, args->pwdlen, args->salt, args->saltlen,
    args->outlen, args->encoded, args->encodedlen);

  return NULL;
}

struct verify_args {
  const char *encoded;
  const char *pwd;
  size_t pwdlen;
  int result;
};

static void *
nogvl_verify(void *data)
{
  struct verify_args *args = data;
  args->result = argon2id_verify(args->encoded, args->pwd, args->pwdlen);

  return NULL;
}

struct hash_encoded_data {
  char *encoded;
  VALUE pwd;
  VALUE salt;
  struct hash_encoded_args args;
};

static VALUE
hash_encoded_body(VALUE arg)
{
  struct hash_encoded_data *data = (struct hash_encoded_data *)arg;

  rb_thread_call_without_gvl(nogvl_hash_encoded, &data->args, NULL, NULL);

  if (data->args.result != ARGON2_OK) {
    rb_raise(cArgon2idError, "%s", argon2_error_message(data->args.result));
  }

  return rb_str_new_cstr(data->encoded);
}

static VALUE
hash_encoded_finalize(VALUE arg)
{
  struct hash_encoded_data *data = (struct hash_encoded_data *)arg;

  RB_GC_GUARD(data->pwd);
  RB_GC_GUARD(data->salt);
  free(data->encoded);

  return Qnil;
}

static VALUE
rb_argon2id_hash_encoded(VALUE klass, VALUE iterations, VALUE memory, VALUE threads, VALUE pwd, VALUE salt, VALUE hashlen)
{
  uint32_t t_cost, m_cost, parallelism, outlen;
  size_t encodedlen;
  long saltlen;
  struct hash_encoded_data data;

  UNUSED(klass);

  /* Coerce pwd and salt to strings, then freeze to protect against mutation. */
  StringValue(pwd);
  pwd = rb_str_new_frozen(pwd);
  StringValue(salt);
  salt = rb_str_new_frozen(salt);

  t_cost = NUM2UINT(iterations);
  m_cost = NUM2UINT(memory);
  parallelism = NUM2UINT(threads);
  outlen = NUM2UINT(hashlen);

  if (RSTRING_LEN(pwd) > UINT32_MAX) {
    rb_raise(rb_eRangeError, "password too long");
  }

  saltlen = RSTRING_LEN(salt);
  if (saltlen > UINT32_MAX) {
    rb_raise(rb_eRangeError, "salt too long");
  }

  encodedlen = argon2_encodedlen(t_cost, m_cost, parallelism, (uint32_t)saltlen, outlen, Argon2_id);
  data.encoded = malloc(encodedlen);
  if (!data.encoded) {
    rb_raise(rb_eNoMemError, "not enough memory to allocate for encoded password");
  }

  data.pwd = pwd;
  data.salt = salt;
  data.args.result = ARGON2_MISSING_ARGS;
  data.args.t_cost = t_cost;
  data.args.m_cost = m_cost;
  data.args.parallelism = parallelism;
  data.args.pwd = RSTRING_PTR(pwd);
  data.args.pwdlen = RSTRING_LEN(pwd);
  data.args.salt = RSTRING_PTR(salt);
  data.args.saltlen = RSTRING_LEN(salt);
  data.args.outlen = outlen;
  data.args.encoded = data.encoded;
  data.args.encodedlen = encodedlen;

  return rb_ensure(hash_encoded_body, (VALUE)&data, hash_encoded_finalize, (VALUE)&data);
}

static VALUE
rb_argon2id_verify(VALUE self, VALUE pwd) {
  VALUE encoded;
  struct verify_args args;

  encoded = rb_ivar_get(self, id_encoded);

  /* Coerce encoded and freeze it before doing the same to pwd. The order here
   * is important to prevent pwd#to_str mutating encoded.
   */
  StringValueCStr(encoded);
  encoded = rb_str_new_frozen(encoded);
  StringValue(pwd);
  pwd = rb_str_new_frozen(pwd);

  args.result = ARGON2_MISSING_ARGS;
  args.encoded = RSTRING_PTR(encoded);
  args.pwd = RSTRING_PTR(pwd);
  args.pwdlen = RSTRING_LEN(pwd);

  rb_thread_call_without_gvl(nogvl_verify, &args, NULL, NULL);

  RB_GC_GUARD(encoded);
  RB_GC_GUARD(pwd);

  if (args.result == ARGON2_OK) {
    return Qtrue;
  }
  if (args.result == ARGON2_VERIFY_MISMATCH) {
    return Qfalse;
  }
  if (args.result == ARGON2_DECODING_FAIL || args.result == ARGON2_DECODING_LENGTH_FAIL) {
    rb_raise(rb_eArgError, "%s", argon2_error_message(args.result));
  }

  rb_raise(cArgon2idError, "%s", argon2_error_message(args.result));
}

void
Init_argon2id(void)
{
  rb_ext_ractor_safe(true);

  id_encoded = rb_intern("@encoded");

  mArgon2id = rb_define_module("Argon2id");
  cArgon2idError = rb_define_class_under(mArgon2id, "Error", rb_eStandardError);
  cArgon2idPassword = rb_define_class_under(mArgon2id, "Password", rb_cObject);
  rb_define_private_method(rb_singleton_class(cArgon2idPassword), "hash_encoded", rb_argon2id_hash_encoded, 6);
  rb_define_private_method(cArgon2idPassword, "verify", rb_argon2id_verify, 1);
}
