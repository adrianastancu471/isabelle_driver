/*	$OpenBSD: octrng.c,v 1.9 2020/05/29 04:42:24 deraadt Exp $	*/
/*
 * Copyright (c) 2013 Paul Irofti <paul@irofti.net>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include "octrng_simpl.h"
#include "timeout.h"

#define OCTRNG_ENTROPY_REG 0
#define OCTRNG_CONTROL_ADDR 0x0001180040000000ULL
#define OCTRNG_RESET  (1UL << 3)
#define OCTRNG_ENABLE_OUTPUT (1UL << 1)
#define OCTRNG_ENABLE_ENTROPY  (1UL << 0)

static struct reg {
  unsigned long control_addr;
} rng_regs;

static unsigned long rand_value;

static void set_register(unsigned long long reg, unsigned long  value) 
{
  switch(reg) {
    case OCTRNG_CONTROL_ADDR:
      rng_regs.control_addr = value;
      break;
    default:
      rng_regs.control_addr = 0;                
      break;
  }
}

static unsigned long get_register(unsigned long long reg) 
{
  switch(reg) {
    case OCTRNG_ENTROPY_REG:
      if ((rng_regs.control_addr&OCTRNG_ENABLE_OUTPUT) &&
        (rng_regs.control_addr&OCTRNG_ENABLE_ENTROPY))
         return get_time();
      break;
    case OCTRNG_CONTROL_ADDR:
      return rng_regs.control_addr;
    default:
      break;
  }
  return 0;
}

void
octrng_rnd(void)
{
	unsigned int value;

	rand_value = get_register(OCTRNG_ENTROPY_REG);
  add_task(octrng_rnd, 10);
}

void
octrng_attach(void)
{
	unsigned long control_reg;

	control_reg = get_register(OCTRNG_CONTROL_ADDR);
	control_reg |= (OCTRNG_ENABLE_OUTPUT | OCTRNG_ENABLE_ENTROPY);
	set_register(OCTRNG_CONTROL_ADDR,control_reg);

  add_task(octrng_rnd, 5);
}
