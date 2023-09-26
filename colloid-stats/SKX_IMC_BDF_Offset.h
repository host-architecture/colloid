// ================ Machine-Dependent Uncore Performance Monitor Locations =================
// These are the most common bus/device/function locations for the IMC counters on 
// Xeon Platinum 8160 (Skylake, SKX)
// These are set up to work on the TACC Stampede2 SKX nodes....
//
// Note that the PmonCtl offsets are for programmable counters 0-3, plus the fixed counter.
//     (The fixed counter only needs bit 22 enabled, most other bits are ignored)
// Note that the PmonCtr offsets are for the bottom 32 bits of a 48 bit counter in a
//     64-bit field.  The first four offsets are for the programmable counters 0-3,
//     and the final value is for the Fixed-Function (DCLK) counter that should
//     always increment at the DCLK frequency (1/2 the DDR transfer frequency).

int IMC_BUS_Socket[4] = {0x24, 0x5a, 0x9a, 0xda};
int IMC_Device_Channel[6] = {0x0a, 0x0a, 0x0b, 0x0c, 0x0c, 0x0d};
int IMC_Function_Channel[6] = {0x02, 0x06, 0x02, 0x02, 0x06, 0x02};
int IMC_PmonCtl_Offset[5] = {0xd8, 0xdc, 0xe0, 0xe4, 0xf0}; 
int IMC_PmonCtr_Offset[5] = {0xa0, 0xa8, 0xb0, 0xb8, 0xd0};

// These are the most common bus/device/function locations for the UPI link-layer counters on 
// Xeon Platinum 8160 (Skylake, SKX)
// These are set up to work on the TACC Stampede2 SKX nodes....
//
// Note that the PmonCtl offsets are for programmable counters 0-3.
// Note that the PmonCtr offsets are for the bottom 32 bits of a 48 bit counter in a
//     64-bit field.  The four offsets are for the programmable counters 0-3.

int UPI_BUS_Socket[4] = {0x32, 0x6d, 0xad, 0xed};
int UPI_Device_Channel[3] = {0x0e, 0x0f, 0x10};
int UPI_Function_Channel[3] = {0x0, 0x0, 0x0};
int UPI_PmonCtl_Offset[4] = {0x350, 0x358, 0x360, 0x368}; 
int UPI_PmonCtr_Offset[4] = {0x318, 0x320, 0x328, 0x330};

// ================ End of Machine-Dependent Uncore Performance Monitor Locations =================