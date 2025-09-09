<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The Bus Transaction FSM is a simple finite state machine that simulates a basic read/write transaction between a master and a slave. The FSM has four states:

IDLE (S_IDLE) – Waits for a request (req) from the master. No transaction activity occurs.

Address Acknowledge (S_ADDR_ACK) – Grants the master’s request by asserting ack and indicates the transaction is busy (busy=1).

Data Phase (S_DATA) – Simulates reading or writing data:

WRITE (rw=0) – The FSM modifies an internal register to emulate a write.

READ (rw=1) – Prepares data for output by toggling the internal register and sets data_valid in the response state.

Response (S_RESP) – Signals transaction completion with a one-cycle done pulse. For read operations, data_valid goes high to indicate valid data is ready.

Top-level I/O mapping:

Inputs (ui_in):

ui[0] = req

ui[1] = rw

ui[2:7] = unused

Outputs (uo_out):

uo[0] = ack

uo[1] = busy

uo[2] = done

uo[3] = data_valid

uo[4:7] = unused

Bidirectional (uio_out, uio_oe) are unused in this design.

The FSM runs on clk with active-low reset (rst_n). On reset, all outputs and internal registers are cleared.

## How to test

Simulation in EDA tool (Vivado, ModelSim, or Wokwi TT-UM playground):

Provide a clock signal to clk.

Toggle ui[0] (req) to request a transaction.

Set ui[1] (rw) to 1 for READ or 0 for WRITE.

Observe outputs:

uo[0] (ack) goes high when the request is accepted.

uo[1] (busy) stays high during the transaction.

uo[2] (done) pulses high for one clock at the end.

uo[3] (data_valid) pulses high for read transactions.

Test sequence example:

Clock ticks: req=1, rw=0 → ack high → busy high → done pulse.

Clock ticks: req=1, rw=1 → ack high → busy high → done pulse and data_valid pulse.

This allows you to verify the correct FSM transitions and output signals.

## External hardware

This project is fully digital and does not require any external hardware to run in simulation.

If implemented on FPGA/TT-UM hardware, you could connect outputs to:

LEDs for ack, busy, done, data_valid

Slide switches for inputs req and rw

List of external hardware (optional):

LEDs for monitoring outputs (uo[0:3])

Slide switches for inputs (ui[0:1])

FPGA board or TT-UM simulator
