# I2C_VIP
Verification of the I2C Protocol with UVM
In this project, I completed the basic communication between a single master and a single slave using 7-bit addressing in standard mode.

LINKS FOR THE REFERENCE:
https://www.i2c-bus.org/addressing/start-byte/
https://www.totalphase.com/support/articles/200349176-7-bit-8-bit-and-10-bit-i2c-slave-addressing/?srsltid=AfmBOorgd4exdp47b9B7zoPMYxEzp5l3Wz8rYzGerLbJc0myq7UMlUsG
https://developerhelp.microchip.com/xwiki/bin/view/applications/i2c/#HI2CRead
https://interrupt.memfault.com/blog/i2c-in-a-nutshell
https://www.nxp.com/docs/en/application-note/AN10216.pdf    (nxp_manual)
https://mu.microchip.com/practical-i2c-introduction-implementation-and-troubleshooting   (manual)

I'm still working on the VIP, making the necessary adjustments and trying to make it more modular and reusable.
In the future, I'd like to make it a 10-bit addressing mode with multi-master and multi-slave support, as well as cover I2C features like bus arbitration and clock stretching across all modes and reset configurations.
