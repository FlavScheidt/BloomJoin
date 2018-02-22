#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdarg.h>
#include <strings.h>
#include <stdint.h>
#include <sys/types.h>
#include <errno.h>
#include <locale.h>
#include <libintl.h>
#include <stdint.h>
#include <math.h>

/***************************************************
  Hash Any
  Postgres default
***************************************************/
#define UINT32_ALIGN_MASK (sizeof(int) - 1)

#define rot(x,k) (((x)<<(k)) | ((x)>>(32-(k))))

#define mix(a,b,c) \
{ \
  a -= c;  a ^= rot(c, 4);	c += b; \
  b -= a;  b ^= rot(a, 6);	a += c; \
  c -= b;  c ^= rot(b, 8);	b += a; \
  a -= c;  a ^= rot(c,16);	c += b; \
  b -= a;  b ^= rot(a,19);	a += c; \
  c -= b;  c ^= rot(b, 4);	b += a; \
}

#define final(a,b,c) \
{ \
  c ^= b; c -= rot(b,14); \
  a ^= c; a -= rot(c,11); \
  b ^= a; b -= rot(a,25); \
  c ^= b; c -= rot(b,16); \
  a ^= c; a -= rot(c, 4); \
  b ^= a; b -= rot(a,14); \
  c ^= b; c -= rot(b,24); \
}

int hash_any(char *k, int keylen);

/*******************************************
  Pearson and Jenkins
  My implementation
********************************************/
typedef  unsigned long  int  ub4;   /* unsigned 4-byte quantities */
typedef  unsigned       char ub1;   /* unsigned 1-byte quantities */

#define hashsize(n) ((ub4)1<<(n))
#define hashmask(n) (hashsize(n)-1)

size_t hash_pearson(const char* s);
size_t hash_jenkins(const char* s);

/*****************************************
MurmurHash2, by Austin Appleby
******************************************/
unsigned int MurmurHash2 ( const void * key, int len, unsigned int seed );

/*****************************************
  MurmurHash3 
 copyright (c) 2014 joseph werle <joseph.werle@gmail.com>
*****************************************/

#ifndef MURMURHASH_H
#define MURMURHASH_H 1

#include <stdint.h>

#define MURMURHASH_VERSION "0.0.3"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Returns a murmur hash of `key' based on `seed'
 * using the MurmurHash3 algorithm
 */

uint32_t
murmurhash3 (const char *, uint32_t, uint32_t);
uint16_t murmurhash316 (const char *key, uint16_t len, uint16_t seed);

#ifdef __cplusplus
}
#endif

#endif

/***************************************
  Multiply Add Shift
  My implementation, based on the Ditritch Paper
****************************************/
int mulAddSh (const char *s, int d);

/***************************************
  FNV1a Hash
  By Stephan Brumme, slightly adapted
****************************************/
// default values recommended by http://isthe.com/chongo/tech/comp/fnv/
#define PRIME 0x01000193 //   16777619
#define SEED 0x811C9DC5 // 2166136261

#define PRIME8 0x00000013 //   19
#define SEED8 0x000000A1 // 161

#define PRIME16 0x00001DC3 //   7619
#define SEED16 0x00008DA5 // 36261

uint32_t fnv1aByte(unsigned char oneByte, uint32_t hash);
uint32_t fnv1aShort(unsigned short twoBytes, uint32_t hash);
uint32_t fnv1a(unsigned int fourBytes);

uint8_t fnv1aByte8(unsigned char oneByte, uint8_t hash);
uint8_t fnv1aShort8(unsigned short twoBytes, uint8_t hash);
uint8_t fnv1a8(unsigned int fourBytes);

uint16_t fnv1aByte16(unsigned char oneByte, uint16_t hash);
uint16_t fnv1aShort16(unsigned short twoBytes, uint16_t hash);
uint16_t fnv1a16(unsigned int fourBytes);


/*************************************
  Elf Hash
  Wikipedia Implementation
*************************************/
unsigned int ElfHash (const char *s);