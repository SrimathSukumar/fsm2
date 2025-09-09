`default_nettype none
`timescale 1ns / 1ps

/* Testbench for bus_transaction_tt_um module using TT-UM template style */

module tb ();

  // Dump the signals to a VCD file
  initial begin
    $dumpfile("tb_bus_transaction_tt_um.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Top-level signals
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate the TT-UM module
  bus_transaction_tt_um dut (
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 100MHz sim-style

  // Test procedure
  initial begin
    // Initialize
    ena = 1;
    rst_n = 0; ui_in = 8'h00; uio_in = 8'h00;
    #20;
    rst_n = 1;

    $display("\n--- Test 1: Single WRITE transaction ---");
    ui_in[1] = 0;  // rw = 0 => WRITE
    #10;
    ui_in[0] = 1;  // req = 1
    #10;
    ui_in[0] = 0;  // req = 0
    #60;

    $display("\n--- Test 2: Single READ transaction ---");
    ui_in[1] = 1;  // rw = 1 => READ
    #10;
    ui_in[0] = 1;  // req = 1
    #10;
    ui_in[0] = 0;  // req = 0
    #60;

    $display("\n--- Test 3: Back-to-back requests ---");
    ui_in[1] = 0; ui_in[0] = 1; #10; ui_in[0] = 0; #30;
    ui_in[1] = 1; ui_in[0] = 1; #10; ui_in[0] = 0; #40;

    #50;
    $finish;
  end

  // Monitor outputs
  initial begin
    $monitor("t=%0t | req=%b rw=%b | ack=%b busy=%b done=%b data_valid=%b",
              $time, ui_in[0], ui_in[1], uo_out[0], uo_out[1], uo_out[2], uo_out[3]);
  end

endmodule
