//io_handler.c
#include "io_handler.h"
#include <stdio.h>

void IO_init(void)
{
	// reset, chip select, r, w are all active low
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
	*otg_hpi_r = 1;
	*otg_hpi_w = 1;
	*otg_hpi_address = 0;
	*otg_hpi_data = 0;
	// Reset OTG chip
	*otg_hpi_cs = 0;
	*otg_hpi_reset = 0;
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
}

void IO_write(alt_u8 Address, alt_u16 Data)
{
	// TODO: follows timing diagram in lecture slides
	*otg_hpi_r = 1;  // not reading
	*otg_hpi_address = Address;
	*otg_hpi_data = Data;

	*otg_hpi_cs = 0;
	*otg_hpi_w = 0;

	// cleanup
	*otg_hpi_w = 1;
	*otg_hpi_cs = 1;
}

alt_u16 IO_read(alt_u8 Address)
{
	alt_u16 data;
	// TODO:
	*otg_hpi_w = 1; // not writing
	*otg_hpi_address = Address;

	*otg_hpi_cs = 0;
	*otg_hpi_r = 0;

	data = *otg_hpi_data; // read data

	// cleanup
	*otg_hpi_r = 1;
	*otg_hpi_cs = 1;

	return data;
}
