/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module bus_transaction_tt_um (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (1=output, 0=input)
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // active-low reset
);

    // Map top-level signals to FSM internal signals
    wire req  = ui_in[0];   // request from master
    wire rw   = ui_in[1];   // 1=READ, 0=WRITE

    // Outputs
    reg ack;
    reg busy;
    reg done;
    reg data_valid;

    // Internal FSM
    localparam [2:0]
        S_IDLE      = 3'b000,
        S_ADDR_ACK  = 3'b001,
        S_DATA      = 3'b010,
        S_RESP      = 3'b011;

    reg [2:0] state, next_state;
    reg [7:0] internal_reg;

    // State register (synchronous)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:      next_state = req ? S_ADDR_ACK : S_IDLE;
            S_ADDR_ACK:  next_state = S_DATA;
            S_DATA:      next_state = S_RESP;
            S_RESP:      next_state = S_IDLE;
            default:     next_state = S_IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ack         <= 0;
            busy        <= 0;
            done        <= 0;
            data_valid  <= 0;
            internal_reg <= 8'h00;
        end else begin
            done        <= 0;
            data_valid  <= 0;

            case (state)
                S_IDLE: begin
                    ack  <= 0;
                    busy <= 0;
                end

                S_ADDR_ACK: begin
                    ack  <= 1;
                    busy <= 1;
                end

                S_DATA: begin
                    ack  <= 1;
                    busy <= 1;
                    if (rw == 1'b0)
                        internal_reg <= internal_reg + 8'h11;  // WRITE simulation
                    else
                        internal_reg <= internal_reg ^ 8'hAA;  // READ simulation
                end

                S_RESP: begin
                    ack  <= 0;
                    busy <= 0;
                    done <= 1;
                    if (rw == 1'b1)
                        data_valid <= 1;
                end

                default: begin
                    ack  <= 0;
                    busy <= 0;
                end
            endcase
        end
    end

    // Map FSM outputs to top-level template outputs
    assign uo_out  = {4'b0, ack, busy, done, data_valid}; // top nibble unused
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Prevent unused warnings
    wire _unused = &{ui_in[2+:6], uio_in, ena};

endmodule
