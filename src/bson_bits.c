#include <SWI-Prolog.h>

/**
 * Get the integer from a term and return it as a byte.
 */
static int
get_int(term_t t)
{
    int val;
    int rc;
    rc = PL_get_integer(t, &val);
    return val;
}

/**
 * Convert 8 bytes into a double (64-bit IEEE 754 floating point).
 */
static foreign_t
bytes8_to_double(
    term_t byte0, term_t byte1, term_t byte2, term_t byte3,
    term_t byte4, term_t byte5, term_t byte6, term_t byte7,
    term_t result)
{
    double val;
    unsigned char *byte = (unsigned char *)&val;

    byte[0] = get_int(byte0);
    byte[1] = get_int(byte1);
    byte[2] = get_int(byte2);
    byte[3] = get_int(byte3);
    byte[4] = get_int(byte4);
    byte[5] = get_int(byte5);
    byte[6] = get_int(byte6);
    byte[7] = get_int(byte7);

    return PL_unify_float(result, val);
}

/**
 * Convert 4 bytes into a long (32-bit). Byte-order is little-endian.
 */
static foreign_t
bytes4_to_int32(
    term_t byte0, term_t byte1, term_t byte2, term_t byte3,
    term_t result)
{
    long val = 0;

    val |= get_int(byte0) << (8*0);
    val |= get_int(byte1) << (8*1);
    val |= get_int(byte2) << (8*2);
    val |= get_int(byte3) << (8*3);

    return PL_unify_integer(result, val);
}

/**
 * Convert 8 bytes into an int64_t (64-bit). Byte-order is little-endian.
 */
static foreign_t
bytes8_to_int64(
    term_t byte0, term_t byte1, term_t byte2, term_t byte3,
    term_t byte4, term_t byte5, term_t byte6, term_t byte7,
    term_t result)
{
    int64_t val = 0;

    val |= (int64_t)get_int(byte0) << (8*0);
    val |= (int64_t)get_int(byte1) << (8*1);
    val |= (int64_t)get_int(byte2) << (8*2);
    val |= (int64_t)get_int(byte3) << (8*3);
    val |= (int64_t)get_int(byte4) << (8*4);
    val |= (int64_t)get_int(byte5) << (8*5);
    val |= (int64_t)get_int(byte6) << (8*6);
    val |= (int64_t)get_int(byte7) << (8*7);

    return PL_unify_int64(result, val);
}

/**
 * Export functions to Prolog. Called implicitly by Prolog's
 * use_foreign_library(foreign(LibPath)).
 */
install_t
install_bson_bits(void)
{
    PL_register_foreign("bytes_to_float",   9, bytes8_to_double, 0);
    PL_register_foreign("bytes_to_integer", 5, bytes4_to_int32,  0);
    PL_register_foreign("bytes_to_integer", 9, bytes8_to_int64,  0);
}
